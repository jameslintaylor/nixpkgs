{ stdenv, fetchurl, icu, expat, zlib, bzip2, python, fixDarwinDylibNames, libiconv
, which
, buildPackages, buildPlatform, hostPlatform
, toolset ? /**/ if stdenv.cc.isClang  then "clang"
            else null
, enableRelease ? true
, enableDebug ? false
, enableSingleThreaded ? false
, enableMultiThreaded ? true
, enableShared ? !(hostPlatform.libc == "msvcrt") # problems for now
, enableStatic ? !enableShared
, enablePython ? false
, enableNumpy ? false
, taggedLayout ? ((enableRelease && enableDebug) || (enableSingleThreaded && enableMultiThreaded) || (enableShared && enableStatic))
, patches ? []
, mpi ? null

# Attributes inherit from specific versions
, version, src
, ...
}:

# We must build at least one type of libraries
assert enableShared || enableStatic;

# Python isn't supported when cross-compiling
assert enablePython -> hostPlatform == buildPlatform;
assert enableNumpy -> enablePython;

with stdenv.lib;
let

  variant = concatStringsSep ","
    (optional enableRelease "release" ++
     optional enableDebug "debug");

  threading = concatStringsSep ","
    (optional enableSingleThreaded "single" ++
     optional enableMultiThreaded "multi");

  link = concatStringsSep ","
    (optional enableShared "shared" ++
     optional enableStatic "static");

  runtime-link = if enableShared then "shared" else "static";

  # To avoid library name collisions
  layout = if taggedLayout then "tagged" else "system";

  b2Args = concatStringsSep " " ([
    "--includedir=$dev/include"
    "--libdir=$out/lib"
    "-j$NIX_BUILD_CORES"
    "--layout=${layout}"
    "variant=${variant}"
    "threading=${threading}"
    "link=${link}"
    "-sEXPAT_INCLUDE=${expat.dev}/include"
    "-sEXPAT_LIBPATH=${expat.out}/lib"

    # TODO: make this unconditional
  ] ++ optionals (hostPlatform != buildPlatform) [
    "address-model=${toString hostPlatform.parsed.cpu.bits}"
    "architecture=${toString hostPlatform.parsed.cpu.family}"
    "binary-format=${toString hostPlatform.parsed.kernel.execFormat.name}"
    "target-os=${toString hostPlatform.parsed.kernel.name}"

    # adapted from table in boost manual
    # https://www.boost.org/doc/libs/1_66_0/libs/context/doc/html/context/architectures.html
    "abi=${if hostPlatform.parsed.cpu.family == "arm" then "aapcs"
           else if hostPlatform.isWindows then "ms"
           else if hostPlatform.isMips then "o32"
           else "sysv"}"
  ] ++ optional (link != "static") "runtime-link=${runtime-link}"
    ++ optional (variant == "release") "debug-symbols=off"
    ++ optional (toolset != null) "toolset=${toolset}"
    ++ optional (mpi != null || hostPlatform != buildPlatform) "--user-config=user-config.jam"
    ++ optionals (hostPlatform.libc == "msvcrt") [
    "threadapi=win32"
  ]);

in

stdenv.mkDerivation {
  name = "boost-${version}";

  inherit src;

  patchFlags = optionalString (hostPlatform.libc == "msvcrt") "-p0";
  patches = patches ++ optional (hostPlatform.libc == "msvcrt") (fetchurl {
    url = "https://svn.boost.org/trac/boost/raw-attachment/tickaet/7262/"
        + "boost-mingw.patch";
    sha256 = "0s32kwll66k50w6r5np1y5g907b7lcpsjhfgr7rsw7q5syhzddyj";
  });

  meta = {
    homepage = http://boost.org/;
    description = "Collection of C++ libraries";
    license = stdenv.lib.licenses.boost;

    platforms = (if versionOlder version "1.59" then remove "aarch64-linux" else id) platforms.unix;
    maintainers = with maintainers; [ peti wkennington ];
  };

  preConfigure = ''
    if test -f tools/build/src/tools/clang-darwin.jam ; then
        substituteInPlace tools/build/src/tools/clang-darwin.jam \
          --replace '@rpath/$(<[1]:D=)' "$out/lib/\$(<[1]:D=)";
    fi;
  '' + optionalString (mpi != null) ''
    cat << EOF >> user-config.jam
    using mpi : ${mpi}/bin/mpiCC ;
    EOF
  '' + optionalString (hostPlatform != buildPlatform) ''
    cat << EOF >> user-config.jam
    using gcc : cross : ${stdenv.cc.targetPrefix}c++ ;
    EOF
  '';

  NIX_CFLAGS_LINK = stdenv.lib.optionalString stdenv.isDarwin
                      "-headerpad_max_install_names";

  enableParallelBuilding = true;

  nativeBuildInputs = [ which buildPackages.stdenv.cc ];
  buildInputs = [ expat zlib bzip2 libiconv ]
    ++ optional (hostPlatform == buildPlatform) icu
    ++ optional stdenv.isDarwin fixDarwinDylibNames
    ++ optional enablePython python
    ++ optional enableNumpy python.pkgs.numpy;

  configureScript = "./bootstrap.sh";
  configurePlatforms = [];
  configureFlags = [
    "--includedir=$(dev)/include"
    "--libdir=$(out)/lib"
  ] ++ optional enablePython "--with-python=${python.interpreter}"
    ++ [ (if hostPlatform == buildPlatform then "--with-icu=${icu.dev}" else "--without-icu") ]
    ++ optional (toolset != null) "--with-toolset=${toolset}";

  buildPhase = ''
    ./b2 ${b2Args}
  '';

  installPhase = ''
    # boostbook is needed by some applications
    mkdir -p $dev/share/boostbook
    cp -a tools/boostbook/{xsl,dtd} $dev/share/boostbook/

    # Let boost install everything else
    ./b2 ${b2Args} install
  '';

  postFixup = ''
    # Make boost header paths relative so that they are not runtime dependencies
    cd "$dev" && find include \( -name '*.hpp' -or -name '*.h' -or -name '*.ipp' \) \
      -exec sed '1i#line 1 "{}"' -i '{}' \;
  '' + optionalString (hostPlatform.libc == "msvcrt") ''
    $RANLIB "$out/lib/"*.a
  '';

  outputs = [ "out" "dev" ];
  setOutputFlags = false;
}
