{ ... }:
let
  course-url = "https://moodle.jku.at/jku/course/view.php?id=16027";
in
{
  home.file = {
    "Desktop/firefox.desktop".text = (builtins.readFile ./desktop/firefox.desktop);
    "Desktop/codeblocks.desktop".text = (builtins.readFile ./desktop/codeblocks.desktop);
    "Desktop/leafpad.desktop".text = (builtins.readFile ./desktop/leafpad.desktop);
    "Desktop/org.kde.konsole.desktop".text = (builtins.readFile ./desktop/org.kde.konsole.desktop);
    "Desktop/org.kde.ark.desktop".text = (builtins.readFile ./desktop/org.kde.ark.desktop);
    "Desktop/moodle-course.desktop".text = ''
      [Desktop Entry]
      Icon=text-html
      Name=Moodle Course
      Type=Link
      URL[$e]=${course-url}
    '';
  };
}
