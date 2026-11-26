{ pkgs, ... }:

{
  programs.anki = {
    enable = true;
    # Optional settings, remove what you don't need
    language = "en_US";
    # addons = [ pkgs.ankiAddons.anki-connect ];
  };
}
