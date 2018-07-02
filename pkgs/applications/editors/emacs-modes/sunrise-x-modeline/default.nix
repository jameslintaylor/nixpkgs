{ stdenv, fetchurl, emacs }:

stdenv.mkDerivation rec {
  version = "2";
  name = "sunrise-x-modeline-${version}";
  srcs = fetchurl {
    url = "https://www.emacswiki.org/emacs/download/sunrise-x-modeline.el";
    sha256 = "034yxgjaj6j0wj69k9zpdlib8jmgx1klm6vd6f3ww401nfn16kpf";
  };

  unpackPhase = "for m in $srcs; do cp $m $(echo $m | cut -d- -f2-); done";
  installPhase = "mkdir -p $out/share/emacs/site-lisp/emacswiki/${name}/; cp *.el *.elc $out/share/emacs/site-lisp/emacswiki/${name}/";

  meta = {
    homepage = https://www.emacswiki.org/emacs/sunrise-x-popviewer.el;
    description = "Modeline enhancement for sunrise commander";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = emacs.meta.platforms;
  };
}
