{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.networks.portmaster;

  portmaster-deb = pkgs.fetchurl {
    url = "https://updates.safing.io/latest/linux_amd64/packages/portmaster-installer.deb";
    sha256 = "sha256-2b9Gn9Hzvuiu/YEeAZRTvJU1Iom06tp0bTC5LhbmghM=";
  };

  portmaster-desktop = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/safing/portmaster-packaging/master/linux/portmaster.desktop";
    sha256 = "sha256-ewwD5FUt2Gyu/y1iixM0bP5wpkavEausZVXjSORsKNo="; # Replace with actual hash
  };

  portmaster-app = pkgs.stdenv.mkDerivation {
    name = "portmaster-desktop";
    src = portmaster-deb;

    nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.dpkg pkgs.makeWrapper ];
    buildInputs = with pkgs; [
      alsa-lib
      mesa
      libdrm
      libglvnd
      vulkan-loader
      libva
      gtk3
      libsecret
      nss
      xorg.libXdamage
      xorg.libXtst
      xorg.libXcomposite
      xorg.libXrandr
      systemd
      networkmanager
      adwaita-icon-theme
    ];

    unpackPhase = "dpkg -x $src .";

    installPhase = ''
      # Main binary
      mkdir -p $out/opt/safing/portmaster
      cp -r opt/safing/portmaster/* $out/opt/safing/portmaster/

      # Systemd service
      mkdir -p $out/etc/systemd/system
      cat > $out/etc/systemd/system/portmaster.service <<EOF
      [Unit]
      Description=Portmaster Privacy App
      Wants=network-online.target
      After=network-online.target

      [Service]
      Type=simple
      ExecStart=$out/opt/safing/portmaster/portmaster-start core --data=/opt/safing/portmaster
      Restart=on-failure
      RestartSec=5s

      [Install]
      WantedBy=multi-user.target
      EOF

      # Desktop integration
      mkdir -p $out/share/applications
      cp ${portmaster-desktop} $out/share/applications/portmaster.desktop
      substituteInPlace $out/share/applications/portmaster.desktop \
        --replace "/opt/safing/portmaster/portmaster-start" "$out/bin/portmaster" \
        --replace "Icon=portmaster" "Icon=$out/share/icons/hicolor/256x256/apps/portmaster.png"

      # Binary wrapper
      mkdir -p $out/bin
      makeWrapper $out/opt/safing/portmaster/portmaster-start $out/bin/portmaster \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath (with pkgs; [
          alsa-lib
          mesa
          libdrm
          libglvnd
          vulkan-loader
          libva
          gtk3
          libsecret
          nss
          xorg.libXdamage
          xorg.libXtst
          xorg.libXcomposite
          xorg.libXrandr
          systemd
          networkmanager
        ])}" \
        --prefix PATH : ${lib.makeBinPath [ pkgs.systemd pkgs.networkmanager ]} \
        --prefix XDG_DATA_DIRS : "$out/share:${pkgs.adwaita-icon-theme}/share"
    '';
  };

in {
  options.modules.networks.portmaster = {
    enable = mkEnableOption "Portmaster application firewall";
    dataDir = mkOption {
      type = types.str;
      default = "/opt/safing/portmaster";
      description = "Data directory for Portmaster";
    };
    autostart = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically start Portmaster on boot";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ portmaster-app ];

    systemd.services.portmaster = {
      description = "Portmaster Privacy App";
      wantedBy = lib.mkIf cfg.autostart [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = "${portmaster-app}/bin/portmaster core --data=${cfg.dataDir}";
        Restart = "on-failure";
        StateDirectory = baseNameOf cfg.dataDir;
        AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_RAW";
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_RAW";
      };
    };

    networking.networkmanager.enable = mkDefault true;
    hardware.graphics.enable = mkDefault true;

    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 8176 -j nixos-fw-accept
    '';
  };
}