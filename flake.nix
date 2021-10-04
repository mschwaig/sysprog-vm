{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }: {

    nixosConfigurations.sysprog-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          ({ pkgs, modulesPath, ... }: {

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
                   '';
                 };
                 memorySize = 4096;
                 vmName = "sysprog 2021WT";
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
              flake = "github:mschwaig/sysprog-vm/main";
              allowReboot = false;
              dates = "*:0/10";
              randomizedDelaySec = "1min";
            };

            # add system packages
            environment.systemPackages = with pkgs; [

              # terminal development tools
              gcc10 clang_12 gnumake valgrind gdb binutils git manpages python38

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
              codeblocks
            ];
            programs.vim.defaultEditor = true;

            environment.gnome.excludePackages = [
              pkgs.gnome.atomix
              pkgs.gnome.cheese
              pkgs.gnome.epiphany
              pkgs.gnome.geary
              pkgs.gnome.gnome-music
              pkgs.gnome.hitori
              pkgs.gnome.iagno
              pkgs.gnome-photos
              pkgs.gnome.tali
              pkgs.gnome.totem
            ];

            services.xserver = {
              enable = true;
              desktopManager.gnome = {
                enable = true;
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
              extraGroups = [ "wheel" ];
              description = "Developer";
              initialPassword = "developer";
            };
          })
        ];
      };
  };
}
