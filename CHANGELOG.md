# [1.2.0](https://github.com/ClementBobin/flakeHypr/compare/v1.1.0...v1.2.0) (2025-06-25)


### Bug Fixes

* :bug: explicitly set battery charge thresholds ([935a1f7](https://github.com/ClementBobin/flakeHypr/commit/935a1f74c1d1735620f7da64bc69e88467bad9cf))
* :bug: mark yubikey touch detection task as complete ([087edab](https://github.com/ClementBobin/flakeHypr/commit/087edab3b5778ca3c6e874673609e0f0ef078e69))


### Features

* add configuration for container engines support ([9b5b159](https://github.com/ClementBobin/flakeHypr/commit/9b5b15917eeaa549b75fe556650bffc313eef147))
* add game configuration module ([bff51e9](https://github.com/ClementBobin/flakeHypr/commit/bff51e92a32d747113b1101d478e73ff335ddf39))
* add hyprland keybindings configuration ([bc3a674](https://github.com/ClementBobin/flakeHypr/commit/bc3a674d6800bd4b13e9fb1faebcebc5ec1b208d))
* add joystick support for games configuration ([844085e](https://github.com/ClementBobin/flakeHypr/commit/844085ef01a77227fb974ac28def7bd4157cbdf2))

# [1.1.0](https://github.com/ClementBobin/flakeHypr/compare/v1.0.0...v1.1.0) (2025-06-13)


### Bug Fixes

* :bug: add option to enable/disable KDE Connect tray indicator ([6923e7f](https://github.com/ClementBobin/flakeHypr/commit/6923e7f25b139e992f8089e96b1c8746f3d75a89))
* :bug: change default value of cli tools list to empty ([2f7b6dc](https://github.com/ClementBobin/flakeHypr/commit/2f7b6dc5a0f805a3fbb0020b0b62178dec310fe8))
* :bug: clean up formatting in flake.nix for deployment checks ([ee22861](https://github.com/ClementBobin/flakeHypr/commit/ee22861fad4548472564e08f57da187f0940df77))
* :bug: correct deployment command for deploy-rs in flake.nix ([cc755d3](https://github.com/ClementBobin/flakeHypr/commit/cc755d3e3941f98ae6a376a712c00140aa46808d))
* :bug: correct placement of scalar.enable in oak configuration ([8b32bc5](https://github.com/ClementBobin/flakeHypr/commit/8b32bc5aea300e31fd1a0e360d35eaa7ac5089de))
* :bug: correct variable assignment syntax in rb script ([dbc65d5](https://github.com/ClementBobin/flakeHypr/commit/dbc65d5e0b940fa4b994933f8874fe6936a0475e))
* :bug: improve error handling in rb script & set default host value ([29746e8](https://github.com/ClementBobin/flakeHypr/commit/29746e8e893485a9c4e9062beb3b7d4e421943fa))
* :bug: refactor home.packages to use concatenation ([2240ca9](https://github.com/ClementBobin/flakeHypr/commit/2240ca9d1e754e8dbeee40edde74bd5f7123897a))
* :bug: refactor home.packages to use proper concatenation syntax ([6702754](https://github.com/ClementBobin/flakeHypr/commit/6702754d19fe30e5e4f80cb7ef0db3a66860fab4))
* :bug: refactor packages configuration for improved driver handling ([02558e0](https://github.com/ClementBobin/flakeHypr/commit/02558e069b90256ad0e2fada884b4253c5c0c71f))
* :bug: refactor packages to use optional concatenation ([63d2707](https://github.com/ClementBobin/flakeHypr/commit/63d27079505df6ccade2650241fefee62e02faa0))
* :bug: remove unused inputs parameter from polkit module ([e482931](https://github.com/ClementBobin/flakeHypr/commit/e482931834bb58b9f80579ec52c4f6083bef8a65))
* :bug: remove unused pkgs parameter from kde-connect module ([c4aad16](https://github.com/ClementBobin/flakeHypr/commit/c4aad166bcbc4173e1f55eb96df7dc480340ac16))
* :bug: remove unused variable 'vars' from default.nix ([b6cc41b](https://github.com/ClementBobin/flakeHypr/commit/b6cc41bc68352022dd1f20f488b328677bf78f74))
* :bug: remove usbcore.autosuspend from powersave configuration ([c0db603](https://github.com/ClementBobin/flakeHypr/commit/c0db603e7dda9ab24d378be8f15b3b4f01aab29d))
* :bug: scx service enablement condition in linux-cachyos.nix ([fe068d0](https://github.com/ClementBobin/flakeHypr/commit/fe068d0876b36f71aabcb72f62ceca0505e900d5))
* :bug: simplify cli and mail service configurations in default.nix ([d709dbf](https://github.com/ClementBobin/flakeHypr/commit/d709dbf2b7f5a0d95cffbe7db86011a05ff7de4d))
* :bug: simplify printing service configuration in print.nix ([1079895](https://github.com/ClementBobin/flakeHypr/commit/107989546897ff1e8beae1b022ae48ce288e2674))
* :bug: update bitwarden package to bitwarden-desktop ([353f2b4](https://github.com/ClementBobin/flakeHypr/commit/353f2b4dc77fca74817b3e11957340a3240291a9))
* :bug: update cli configuration to reflect global tools structure ([b83538a](https://github.com/ClementBobin/flakeHypr/commit/b83538a22738fab3ef795513817826bbfafb5b7d))
* :bug: update default mail services to an empty list ([fa000df](https://github.com/ClementBobin/flakeHypr/commit/fa000df5e96441e313eac32f0890af36e82ee449))
* :bug: update default path for Steam compatibility tools ([6fc4ed9](https://github.com/ClementBobin/flakeHypr/commit/6fc4ed9bca6db71a3b4983d417c6c194f269d337))
* :bug: update imports to reference hydenix and remove default.nix ([5a91723](https://github.com/ClementBobin/flakeHypr/commit/5a9172382e8b63449d04bc42ed8645a578e8af7a))
* :bug: update password manager to enable u2f support ([e1faf67](https://github.com/ClementBobin/flakeHypr/commit/e1faf672ab39c1706c0bf5e09a8976af022ebb96))
* :bug: update steam compatibility tools path type ([5f2a69a](https://github.com/ClementBobin/flakeHypr/commit/5f2a69ac6b28d4b3ae041f5bc15d10bf95433f69))
* :bug: update system.stateversion to 25.05 in default.nix ([b7eac36](https://github.com/ClementBobin/flakeHypr/commit/b7eac3691337b2e587cecaab8d9cc16eb4934bfe))


### Features

* :sparkles: add browser module with emulator and driver support ([b34e299](https://github.com/ClementBobin/flakeHypr/commit/b34e2990b1b44f31ced9ab691e0555ebea0461fd))
* :sparkles: add cli configuration for node.js deployments ([2785e34](https://github.com/ClementBobin/flakeHypr/commit/2785e34f37de35e5f40397945ab8cdbc18462699))
* :sparkles: add configuration for game engine installation ([096bd2a](https://github.com/ClementBobin/flakeHypr/commit/096bd2a15ed9e73434b45aab61b4af77fd64e054))
* :sparkles: add customizable printer driver options ([d22b05b](https://github.com/ClementBobin/flakeHypr/commit/d22b05b00f0e1da3038b2cf406339dc7572ad187))
* :sparkles: add kde connect utility module ([064f4d8](https://github.com/ClementBobin/flakeHypr/commit/064f4d8ed41db5660e2a57465add18a8f8570959))
* :sparkles: add option to conditionally enable scx service ([97e3304](https://github.com/ClementBobin/flakeHypr/commit/97e3304e2426d2f526ad9b9fa1956914234613d1))
* :sparkles: add polkit configuration for udisks2 permissions ([f196f9f](https://github.com/ClementBobin/flakeHypr/commit/f196f9f988c366c19a5752cbeb5557ca02d0c444))
* :sparkles: add power saving module with battery health ([98e6ecb](https://github.com/ClementBobin/flakeHypr/commit/98e6ecb63cde44bacb1a779662dfa0bb6e1d429d))
* :sparkles: add support for okular document editor in configuration ([b1bc89b](https://github.com/ClementBobin/flakeHypr/commit/b1bc89b0addde2242c62b9b99661a47495ce61b0))
* :sparkles: add yubikey support and password manager backend ([1cf325b](https://github.com/ClementBobin/flakeHypr/commit/1cf325b02d3c47dd8ca7e385fb01121471ce9760))
* :sparkles: extend chromium driver to include vivaldi and brave ([ad207e7](https://github.com/ClementBobin/flakeHypr/commit/ad207e71e0dd3e8286807d3d7d504309660ce46a))
* :sparkles: gamemode support with customizable settings ([40051db](https://github.com/ClementBobin/flakeHypr/commit/40051dba3ed398164481d22cf6c612e4c6f35b0f))
* :sparkles: integrate deploy-rs and update flake configuration ([e8647f3](https://github.com/ClementBobin/flakeHypr/commit/e8647f39c0356fe39b3628084bd3675de621edc6))
* :sparkles: move cli configuration ([0ad641c](https://github.com/ClementBobin/flakeHypr/commit/0ad641c35ff64cbb9eebe111b03ce7c57599426c))

# 1.0.0 (2025-06-12)


### Bug Fixes

* blacklisted nvidia again ([3c6f4e6](https://github.com/ClementBobin/flakeHypr/commit/3c6f4e6514ea9f8a6dc124beda622fdb98ab7928))
* errors for rebuild ([c4636c9](https://github.com/ClementBobin/flakeHypr/commit/c4636c9387e6b82e72720f6653feaae0db006641))
* hyprland monitor workspace setup ([d652b38](https://github.com/ClementBobin/flakeHypr/commit/d652b38001031b23f515892b244fbe7a30d3d5ec))
* plex filesystem ([60e2bf7](https://github.com/ClementBobin/flakeHypr/commit/60e2bf77be56dc66b92c52757cead6fd24859f6b))
* plex fix ([184a177](https://github.com/ClementBobin/flakeHypr/commit/184a17799c4c6e473131824fc8134044ce92186a))
* url for hydenix instead of path ([41f5be0](https://github.com/ClementBobin/flakeHypr/commit/41f5be058fcfe3f264c0afd2b5dedacfd0f9831e))
* user ssh ([56ca642](https://github.com/ClementBobin/flakeHypr/commit/56ca64284e3e4765cf04cbf1be33cb0eda32cb15))


### Features

* add disk usage analyzers configuration in Nix ([3f73deb](https://github.com/ClementBobin/flakeHypr/commit/3f73deb9c902f3b106dbc34d966544ff4fb5b65e))
* add enable options for various applications and tools, including Stacer, AMD GPU support, and game launchers ([9e290f0](https://github.com/ClementBobin/flakeHypr/commit/9e290f05c3808f5d1d620186369fe4054ca33c43))
* add flake-utils and systems inputs to flake.lock and flake.nix ([078f5f0](https://github.com/ClementBobin/flakeHypr/commit/078f5f04a77b679cd36d7b040c7e5e3e3d510b1d))
* add Flatpak development environment configuration in Nix ([9742bc9](https://github.com/ClementBobin/flakeHypr/commit/9742bc9de6b5d7374128361cf2fbcf1e9e083511))
* add Flutter development environment configuration in Nix ([4e0e712](https://github.com/ClementBobin/flakeHypr/commit/4e0e71203d3392b1b6ac15b2433b8430f46a458c))
* add pm2 support and enable localtunnel in configuration; refactor docker settings ([4b99659](https://github.com/ClementBobin/flakeHypr/commit/4b99659caf2e5e92c1b9a4977b57d5990fb29514))
* add Portmaster application firewall configuration in Nix ([66ef307](https://github.com/ClementBobin/flakeHypr/commit/66ef3074d7e201cee1b5cb63c0164802c951d448))
* add Prisma ORM support for Node.js applications in Nix configuration ([0329f03](https://github.com/ClementBobin/flakeHypr/commit/0329f035804577c635321f066c28da35af08dac4))
* add support for new development tools and games ([80e9361](https://github.com/ClementBobin/flakeHypr/commit/80e9361d2b069682acc482b61465cb6853be8bdb))
* add support for new games and development tools, including GitKraken, Vercel, and Graphite ([1fb9561](https://github.com/ClementBobin/flakeHypr/commit/1fb9561b3131a6f4682a931af9e4c19c7f85e386))
* add Unity Hub support for managing Unity installations in Nix configuration ([b276ba4](https://github.com/ClementBobin/flakeHypr/commit/b276ba483d19d7decbfcf61e43e35d05217fb2e5))
* add VS Code support and Obsidian backup functionality ([6284463](https://github.com/ClementBobin/flakeHypr/commit/628446362083ab173fa178a2c30080d57ba26cb5))
* added initial obsidian module ([803d1d5](https://github.com/ClementBobin/flakeHypr/commit/803d1d5aca50b58800974d03616b39061890db09))
* disable Stacer and LocalTunnel in default configuration ([9a560d4](https://github.com/ClementBobin/flakeHypr/commit/9a560d4fbb9dd10418c3a48a79c95e371d507679))
* enhance development environment with extra package support for Python, Node.js, and Flutter ([098a45f](https://github.com/ClementBobin/flakeHypr/commit/098a45f8ab3264ad4fac663d61ced50c822d0d89))
* enhance gaming configuration and support for new tools ([1c0ed8e](https://github.com/ClementBobin/flakeHypr/commit/1c0ed8eae16ec751d47d5d5882bc51b59d6bd226))
* enhance Nix configurations for Android SDK, BlueMail, JetBrains, Node.js, Flutter, and antivirus settings ([a683984](https://github.com/ClementBobin/flakeHypr/commit/a6839842747be5abddd772f728b7461beccf2028))
* fix plex, openrgb module ([2c541d2](https://github.com/ClementBobin/flakeHypr/commit/2c541d2869c4e078f736ca22f0f940cb45417e7b))
* git module ([d12b78f](https://github.com/ClementBobin/flakeHypr/commit/d12b78fdcffd6a0afb98b2806e027f7d55382e47))
* improve antivirus configuration by using optionals for package management ([95687e6](https://github.com/ClementBobin/flakeHypr/commit/95687e69b071a7e336865e6b75530f55ac42c154))
* init dots ([b529394](https://github.com/ClementBobin/flakeHypr/commit/b52939425016c5b5468e58aefa30e722c56fbaed))
* migrated to hydenix v2 ([e59ce29](https://github.com/ClementBobin/flakeHypr/commit/e59ce2989c387abf126899f64faa244bbfbbffa8))
* multi host and user setup, added oak ([aafed44](https://github.com/ClementBobin/flakeHypr/commit/aafed4455c085b42f2c95541863a6b609c167037))
* refactor Nix configuration for fern host and update driver imports ([7440534](https://github.com/ClementBobin/flakeHypr/commit/74405347073ada299b8609fb1627a12989beb415))
* remove outdated flake.lock update workflow and Flutter/Unity configurations ([9485ff1](https://github.com/ClementBobin/flakeHypr/commit/9485ff199cad9134d658902a61e1b3bdebce61b4))
* replace 'act' with 'openssl' in nix configuration ([d09d70e](https://github.com/ClementBobin/flakeHypr/commit/d09d70e215b820ba5130b0f7805a66ca59a0d0a2))
* simplify bluemail GPU wrapper configuration ([86e16bb](https://github.com/ClementBobin/flakeHypr/commit/86e16bbd60408aeef7281c1a1d10756679730782))
* update homePath in Python devShell configuration to point to Templates directory ([ef519ec](https://github.com/ClementBobin/flakeHypr/commit/ef519ec39115a38a957999b4d0734ccb6a4fe647))
* update JetBrains package references in nix configuration ([8292a16](https://github.com/ClementBobin/flakeHypr/commit/8292a1607a8bdd4a83b791b31231bd3ce8acc28f))
* update keybindings for MangoHud settings ([f06cbc0](https://github.com/ClementBobin/flakeHypr/commit/f06cbc00eb22af59fa578ae966375b11c3e73ebe))
* update Nix configuration to correctly reference dev-global module path ([4371e03](https://github.com/ClementBobin/flakeHypr/commit/4371e038b976911778e4f20a27bcf66812ec244c))
* update Nix configuration to enable Flutter and Android Studio support ([4264c53](https://github.com/ClementBobin/flakeHypr/commit/4264c530fcb1a2637b8c518430506485fca80a89))
* update Nix configurations for Bluemail and improve ignore file handling ([6970264](https://github.com/ClementBobin/flakeHypr/commit/69702640fc902f159bb9385bd8514d3006f325ef))
* update Nix configurations for printing, network tunneling, and various module enhancements ([6d3f79c](https://github.com/ClementBobin/flakeHypr/commit/6d3f79c517bb81d291205286ca14d50161acd6ee))
* update scalar desktop application packaging in Nix configuration ([0746194](https://github.com/ClementBobin/flakeHypr/commit/0746194a0b5151c2b0f76e4c84af2e741084304d))
* update TODO list with task completion and new items ([c104ae1](https://github.com/ClementBobin/flakeHypr/commit/c104ae18479f7727165f044d7fab67344d8d35e3))
* upped config limit in grub ([9ac815a](https://github.com/ClementBobin/flakeHypr/commit/9ac815a08913fd0b0743f5d07a5ae01770279df9))
