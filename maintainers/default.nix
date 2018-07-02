{ pkgs ? (import <nixpkgs> { }) }:

with pkgs;
{
  myEmacs = emacsWithPackages (epkgs: (with epkgs.melpaPackages; [
    evil
    epkgs.icicles
  ]));
}
