{ stdenv, fetchurl, emacs }:

stdenv.mkDerivation rec {
  version = "2018-06-05";
  name = "dired-plus-${version}";
  srcs = fetchurl {
    url = "https://www.emacswiki.org/emacs/download/dired+.el";
    sha256 = "1jv06vj95fzwmswxi9dkrqbslf0cjczw4ha9fyjr1gsfppkr8xvg";
  };
  
  buildInputs = [ emacs ];
  unpackPhase = "for m in $srcs; do cp $m $(echo $m | cut -d- -f2-); done";
  buildPhase = "emacs --batch -L . -f batch-byte-compile *.el";
  installPhase = "mkdir -p $out/share/emacs/site-lisp/emacswiki/${name}/; cp *.el *.elc $out/share/emacs/site-lisp/emacswiki/${name}/";

  meta = {
    homepage = https://www.emacswiki.org/emacs/DiredPlus;
    description = "Enhancements to emacs dired-mode";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = emacs.meta.platforms;
  };
}
