{
  ...
}:
{
  imports = [
    ./communication/mail/bluemail.nix
    ./communication/mail/thunderbird.nix
    ./communication/teams.nix

    ./dev/editor/dbeaver.nix
    ./dev/editor/jetbrains.nix
    ./dev/editor/vs-code.nix
    ./dev/editor/android-studio.nix
    ./dev/global-tools/act-github.nix
    ./dev/global-tools/nix.nix
    ./dev/node/graphite.nix
    ./dev/node/localtunnel.nix
    ./dev/node/node.nix
    ./dev/node/pm2.nix
    ./dev/node/prisma.nix
    ./dev/node/vercel.nix
    ./dev/dotnet.nix
    ./dev/python.nix
    ./dev/rust.nix

    ./documentation/obsidian.nix
    ./documentation/okular.nix
    ./documentation/onlyoffice.nix

    ./driver/chrome.nix

    ./emulator/playonlinux.nix
    ./emulator/proton.nix
    ./emulator/wine.nix

    ./engine/engine.nix

    ./games/mangohud.nix
    ./games/minecraft.nix
    ./games/roblox.nix
    ./games/rocket-league.nix
    ./games/star-citizen.nix
    ./games/northstar.nix

    ./multimedia/easyeffects.nix
    ./multimedia/gimp.nix
    ./multimedia/mpv.nix
    ./multimedia/obs.nix
    ./multimedia/openshot-qt.nix
    ./multimedia/parsec.nix
    ./multimedia/stremio.nix

    ./shell/btop.nix
    ./shell/fzf.nix
    ./shell/navi.nix
    ./shell/ranger.nix
    ./shell/starship.nix
    ./shell/tools.nix

    ./utilities/filezilla.nix
    ./utilities/gitkraken.nix
    ./utilities/scalar.nix
    ./utilities/stacer.nix
  ];
}
