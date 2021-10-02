{ ... }:
let
  course-url = "https://moodle.jku.at/jku/course/view.php?id=16027";
in
  {
    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = [
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
    "Desktop/moodle-course.desktop".text = ''
      [Desktop Entry]
      Icon=text-html
      Name=Moodle Course
      Type=Link
      URL[$e]=${course-url}
    '';
  };
}
