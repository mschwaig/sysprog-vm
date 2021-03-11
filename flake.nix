{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {

    nixosConfigurations.sysprog-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          ({ pkgs, modulesPath, ... }: {

             imports = [ (modulesPath + "/virtualisation/virtualbox-image.nix") {
               virtualbox = {
                 params = {
                   cpus = "2";
                   usb = "off";
                   usbehci = "off";
                   mouse = "ps2";
                   nic1 = "nat";
                   ostype = "Linux_64";
                   description = ''
                     Regular user
                     name: developer, password: sysprog

                     Root user
                     name: root, password: sysprog
                   '';
                 };
                 memorySize = 4096;
                 vmName = "sysprog 2021S";
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

            system.autoUpgrade = {
              enable = true;
              flake = "git+https://github.com/mschwaig/sysprog-vm.git";
              allowReboot = true;
              dates = "*:0/10";
              randomizedDelaySec = "1min";
            };

            # add system packages
            environment.systemPackages = with pkgs; [
              gcc gnumake valgrind gdb binutils git glxinfo (neovim.override { vimAlias = true; }) nano

              htop zip unzip gnutar

              firefox codeblocks gnome3.gedit
            ];
            programs.vim.defaultEditor = true;

            services.xserver = {
              enable = true;
              desktopManager.plasma5 = {
                enable = true;
              };
              libinput.enable = true; # for touchpad support on many laptops
            };

            # Enable sound in virtualbox appliances.
            hardware.pulseaudio.enable = true;

            boot.cleanTmpDir = true;
            networking.hostName = "sysprog-dev";
            networking.firewall.allowPing = true;

           users.users.root = {
              initialPassword = "sysprog";
            };

            users.users.developer = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              description = "Developer";
              initialPassword = "sysprog";
            };
          })
        ];
      };
  };
}
