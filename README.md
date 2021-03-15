# How to build the VirtualBox image yourself

With the Nix package manager with flake support installed run

nix build .#nixosConfigurations.sysprog-vm.config.system.build.virtualBoxOVA

Afterwards you will find the built image inside the `result/` subfolder.

## How to set up the Nix package manager with flake support

These steps help you set up the Nix package manager with support for a experimental more user-friendly command language and a defined package format called flakes that makes it easier to create builds in a strictly determined environment, so that they create the same outputs on various machines or in CI.

The described install is a multi-user install, which is recommended. If you want to know more you can [read the install section in the Nix manual directly](https://nixos.org/manual/nix/stable/#ch-installing-binary) or take a look at the official install page at [https://nixos.org/download.html](https://nixos.org/download.html).

### Step 1: Install the Nix package manager

Run the following command with sudo but not directly as root:

```
$ sh <(curl -L https://nixos.org/nix/install) --daemon
```

Note that you can also download the shell script first and inspect it before you run it.

You might have to re-open your terminals, restart your graphical session or even reboot after this step.

### Step 2: Enable the right experimental features

First run the following comand
```
nix-env -iA nixpkgs.nixFlakes
```

and then add the following lines to `/etc/nix/nix.conf`

```
experimental-features = nix-command flakes
```

You might have to re-open your terminals, restart your graphical session or even reboot after this step.

### Step 3: Verify

The following command should now give similar output.

```
$ nix flake --help
Usage: nix flake COMMAND FLAGS... ARGS...

Common flags:

Available commands:
  archive      copy a flake and all its inputs to a store
  check        check whether the flake evaluates and run its tests
  clone        clone flake repository
  info         list info about a given flake
  init         create a flake in the current directory from a template
  list-inputs  list flake inputs
  new          create a flake in the specified directory from a template
  show         show the outputs provided by a flake
  update       update flake lock file

Note: this program is EXPERIMENTAL and subject to change.
```

