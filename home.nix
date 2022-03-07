{ ... }:
let
  course-url = "https://moodle.jku.at/jku/course/view.php?id=16027";
in
{
  # To fix 'command-not-found' inside shell
  # https://discourse.nixos.org/t/command-not-found-unable-to-open-database/3807/9
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
  };

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "moodle-course.desktop"
        "firefox.desktop"
        "codeblocks.desktop"
        "org.gnome.Nautilus.desktop"
        "moodle-course.desktop"
        "org.gnome.Terminal.desktop"
        "org.gnome.gedit.desktop"
      ];
    };
  };
  # TODO: fix this so that is shows up in gnome
  home.file = {
    ".local/share/applications/moodle-course.desktop".text = ''
      [Desktop Entry]
      Icon=text-html
      Name=Moodle Course
      Type=Link
      URL=${course-url}
    '';
  };
}
