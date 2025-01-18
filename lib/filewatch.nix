pkgs: let
  inotifywait = "${pkgs.inotify-tools}/bin/inotifywait";
  filewatch = (
    # `echo` and `true` are bash builtins
    pkgs.writeShellScriptBin "filewatch"
    ''
      if [[ "$#" -lt 1 ]];
      then
        echo "Needs one argument!"
        exit 1
      fi

      command="$1"

      shift


      while true
      do
        "$SHELL" -c "$command"
        ${inotifywait} "$@" -e modify,create,delete,unmount,move,attrib 2>/dev/null 1>/dev/null
      done
    ''
  );
in
  filewatch
