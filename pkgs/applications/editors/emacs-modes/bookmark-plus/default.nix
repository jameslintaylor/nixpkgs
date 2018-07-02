{ stdenv, fetchurl, emacs }:

let
  modules = [
    { name = "bookmark+.el"; sha256 = "19nycpmsvr586a2fcv4ln32hdjha8n3g06qnz97swh42pnmwkqds"; }
    { name = "bookmark+-mac.el"; sha256 = "0jv8rnwzkx8g1lkah0bpp3qm4phlms5c621kz369vh9xh0l8vbiz"; }
    { name = "bookmark+-bmu.el"; sha256 = "1d88v8knm54ymg25sqgnam8h6syzkggzcxhhq60skbh7qmiimgga"; }
    { name = "bookmark+-1.el"; sha256 = "1cfwzyhqla2rrg3cp8njjqf23d8511746nb55l040iq7fygari0g"; }
    { name = "bookmark+-key.el"; sha256 = "0mywlbvdyyzf4lca21p29ayqa4zimlmvdg66csf92hz51xznzc3h"; }
    { name = "bookmark+-lit.el"; sha256 = "12z5xjpk8pf3m71vfp24biivwka9fswyrvlgs6hv2n7m2f6rni8s"; }
    { name = "bookmark+-doc.el"; sha256 = "0wwvcr2ypwl75pf8d5j53q6jlrx3ai8dacia8n0rx1zay45f13yv"; }
    { name = "bookmark+-chg.el"; sha256 = "196jdr80jp2y6kk8wpn2fsl5sn840c5gxcx6d9m1x06xx2q495dj"; }
  ];

  forAll = f: map f modules;
in
stdenv.mkDerivation rec {
  version = "2018-04-16";
  name = "icicles-${version}";

  srcs = forAll ({name, sha256}: fetchurl { url = "http://www.emacswiki.org/emacs/download/${name}"; inherit sha256; });

  buildInputs = [ emacs ];

  unpackPhase = "for m in $srcs; do cp $m $(echo $m | cut -d- -f2-); done";

  buildPhase = "emacs --batch -L . -f batch-byte-compile *.el";

  installPhase = "mkdir -p $out/share/emacs/site-lisp/emacswiki/${name}/; cp *.el *.elc $out/share/emacs/site-lisp/emacswiki/${name}/";

  meta = {
    homepage = http://www.emacswiki.org/emacs/BookmarkPlus;
    description = "Enhances emacs bookmarks in many ways.";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms   = emacs.meta.platforms;
  };
}
