{ stdenv, fetchurl, emacs }:

stdenv.mkDerivation rec {
  version = "3";
  name = "sunrise-x-popviewer-${version}";
  srcs = fetchurl {
    url = "https://www.emacswiki.org/emacs/download/sunrise-x-popviewer.el";
    sha256 = "1r70dv1nyqz7fng8g7w8c8gh37iapfpfzlhl9jp5gbanrhzd1qi1";
  };
  
  unpackPhase = "for m in $srcs; do cp $m $(echo $m | cut -d- -f2-); done";
  installPhase = "mkdir -p $out/share/emacs/site-lisp/emacswiki/${name}/; cp *.el *.elc $out/share/emacs/site-lisp/emacswiki/${name}/";

  meta = {
    homepage = https://www.emacswiki.org/emacs/sunrise-x-popviewer.el;
    description = "Popviewer extension for sunrise commander";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = emacs.meta.platforms;
  };
}
