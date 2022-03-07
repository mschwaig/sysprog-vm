{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }: {

    nixosConfigurations.sysprog-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          ({ pkgs, modulesPath, ... }:
          let
            codeblocks_patched = pkgs.codeblocks.overrideAttrs (attrs: {
              patches = attrs.patches ++ [ ./envar_config.patch ];
              nativeBuildInputs = attrs.nativeBuildInputs ++ [ pkgs.makeWrapper ];
              postInstall = ''
                wrapProgram "$out/bin/codeblocks" \
                --prefix CB_DEFAULT_CONSOLE_TERM : "gnome-terminal -t \$TITLE -x" \
              '';
            });
          in {
            imports = [
              home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.developer = import ./home.nix;
            }

              (modulesPath + "/virtualisation/virtualbox-image.nix") {
               virtualbox = {
                 params = {
                   cpus = "2";
                   graphicscontroller = "vmsvga";
                   vram = "128";
                   usb = "off";
                   usbehci = "off";
                   mouse = "ps2";
                   nic1 = "nat";
                   ostype = "Linux_64";
                   description = ''
                     Regular user
                     name: developer, password: developer

                     Root user
                     name: root, password: developer

                     Consider enabeling 3D Acceleration:
                     Machine -> Settings -> Display -> Enable 3D Acceleration
                   '';
                 };
                 memorySize = 4096;
                 vmName = "sysprog 2022ST";
               };
             }];
            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            # The qemu-vm module does this out of the box.
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
            virtualisation.virtualbox.guest.enable = true;

            # add language features that enable flakes
            nix = {
              package = pkgs.nixFlakes;
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
            };

            time.timeZone = "Europe/Vienna";

            system.autoUpgrade = {
              enable = true;
              flake = "github:mschwaig/sysprog-vm/st22";
              allowReboot = false;
              dates = "*:0/10";
              randomizedDelaySec = "1min";
            };

            # add system packages
            environment.systemPackages = with pkgs; [

              # terminal development tools
              gcc11 clang_13 gnumake valgrind gdb binutils git manpages python38

              # debugging in a browser
              gdbgui

              # terminal text editors vim and nano
              (neovim.override { vimAlias = true; }) nano

              # system load montitoring tool
              htop

              # graphics diagnosis tool
              glxinfo

              # archiving terminal utilities
              zip unzip gnutar

              # browser
              firefox

              # IDE
              codeblocks_patched
            ];

            environment.gnome.excludePackages = with pkgs; with pkgs.gnome; [
              atomix
              cheese
              epiphany
              evince
              geary
              gnome-characters
              gnome-clocks
              gnome-contacts
              gnome-maps
              gnome-calendar
              gnome-connections
              gnome-music
              gnome-weather
              hitori
              iagno
              gnome-photos
              seahorse
              simple-scan
              tali
              totem
            ];

            programs.fish.enable = true;
            programs.vim.defaultEditor = true;

            services.xserver = {
              enable = true;
              desktopManager = {
                xterm.enable = false;
                gnome.enable = true;
              };

              displayManager = {
                autoLogin.enable = true;
                autoLogin.user = "developer";
              };
              layout = "de,us";
              libinput.enable = true; # for touchpad support on many laptops
            };

            # use same keyboard config as xserver
            console.useXkbConfig = true;

            # Enable sound in virtualbox appliances.
            hardware.pulseaudio.enable = true;

            boot.cleanTmpDir = true;
            networking.hostName = "sysprog-vm";
            networking.firewall.allowPing = true;

            users.users.root = {
              initialPassword = "developer";
            };

            users.users.developer = {
              isNormalUser = true;
              extraGroups = [ "wheel" "vboxsf" ];
              description = "Developer";
              shell = pkgs.fish;
              initialPassword = "developer";
            };
          })
        ];
      };
  };
}
