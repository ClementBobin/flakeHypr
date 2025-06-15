{
  ...
}:
{
  imports = [
    ./browser

    ./communication/mail
    ./communication/teams.nix

    ./dev/editor/dbeaver.nix
    ./dev/editor/jetbrains.nix
    ./dev/editor/vs-code.nix
    ./dev/editor/android-studio.nix
    ./dev/global-tools/act-github.nix
    ./dev/global-tools/nix.nix
    ./dev/global-tools/cli.nix
    ./dev/node/node.nix
    ./dev/node/pm2.nix
    ./dev/node/prisma.nix
    ./dev/dotnet.nix
    ./dev/python.nix
    ./dev/rust.nix

    ./documentation/obsidian.nix
    ./documentation

    ./emulator

    ./engine

    #./extra/ignore-file-retriever.nix

    ./games/joystick.nix
    ./games/mangohud.nix
    ./games/games.nix
    #./games/minecraft.nix
    #./games/roblox.nix
    #./games/rocket-league.nix
    #./games/star-citizen.nix
    #./games/northstar.nix

    ./multimedia/gimp.nix
    ./multimedia/mpv.nix
    ./multimedia/obs.nix
    ./multimedia/openshot-qt.nix
    ./multimedia/parsec.nix
    ./multimedia/stremio.nix

    ./network/tunnel.nix

    ./shell/btop.nix
    ./shell/fzf.nix
    ./shell/navi.nix
    ./shell/ranger.nix
    ./shell/starship.nix
    ./shell/tools.nix

    ./utilities/filezilla.nix
    ./utilities/kde-connect.nix
    ./utilities/scalar.nix
    ./utilities/stacer.nix
  ];
}
