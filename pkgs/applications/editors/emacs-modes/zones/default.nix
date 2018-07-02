{ stdenv, fetchurl, emacs }:

stdenv.mkDerivation rec {
  version = "2018-06-06";
  name = "zones-${version}";
  srcs = fetchurl {
    url = "http://www.emacswiki.org/emacs/download/zones.el";
    sha256 = "11k5g5c9rjd7c0j9yy7i9ycx18fsf7mjj6jl595s8fv1y2qxcinq";
  };

  buildInputs = [ emacs ];
  unpackPhase = "for m in $srcs; do cp $m $(echo $m | cut -d- -f2-); done";
  buildPhase = "emacs --batch -L . -f batch-byte-compile *.el";
  installPhase = "mkdir -p $out/share/emacs/site-lisp/emacswiki/${name}/; cp *.el *.elc $out/share/emacs/site-lisp/emacswiki/${name}/";

  meta = {
    homepage = http://www.emacswiki.org/emacs/Zones;
    description = "Regions on steroids.";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms   = emacs.meta.platforms;
  };
}
