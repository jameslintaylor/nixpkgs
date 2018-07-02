{ stdenv, fetchurl, emacs }:

stdenv.mkDerivation rec {
  version = "2018-04-16";
  name = "mb-depth-plus-${version}";

  srcs = fetchurl {
    url = "http://www.emacswiki.org/emacs/download/mb-depth+.el";
    sha256 = "0yc7fsc9ba0gysdr4h6x284ap8gj1cfgy2pdmxynqkyz9lmzgwf2";
  };

  buildInputs = [ emacs ];
  unpackPhase = "for m in $srcs; do cp $m $(echo $m | cut -d- -f2-); done";
  buildPhase = "emacs --batch -L . -f batch-byte-compile *.el";
  installPhase = "mkdir -p $out/share/emacs/site-lisp/emacswiki/${name}/; cp *.el *.elc $out/share/emacs/site-lisp/emacswiki/${name}/";

  meta = {
    homepage = https://www.emacswiki.org/emacs/MinibufferDepthIndicator;
    description = "Enhances minibuffer depth indicator.";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms   = emacs.meta.platforms;
  };
}
