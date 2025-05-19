{
  ...
}:
{
  imports = [
    ./communication/mail/bluemail.nix
    ./communication/mail/thunderbird.nix
    ./communication/teams.nix

    ./dev/dbeaver.nix
    ./dev/dotnet.nix
    ./dev/flutter.nix
    ./dev/gitkraken.nix
    ./dev/jetbrains.nix
    ./dev/nix.nix
    ./dev/node.nix
    ./dev/python.nix

    ./documentation/obsidian.nix
    ./documentation/okular.nix
    ./documentation/onlyoffice.nix

    ./driver/chrome.nix
    
    ./emulator/playonlinux.nix
    ./emulator/proton.nix
    ./emulator/wine.nix

    ./engine/unity.nix

    ./games/mangohud.nix
    ./games/minecraft.nix

    ./multimedia/easyeffects.nix
    ./multimedia/gimp.nix
    ./multimedia/mpv.nix
    ./multimedia/obs.nix
    ./multimedia/openshot-qt.nix
    ./multimedia/parsec.nix
    ./multimedia/stremio.nix

    ./security/clamav.nix
    ./security/stacer.nix

    ./shell/btop.nix
    ./shell/fzf.nix
    ./shell/navi.nix
    ./shell/ranger.nix
    ./shell/starship.nix
    ./shell/tools.nix

    ./utilities/filezilla.nix
  ];
}
