pkgs: let
  inotifywait = "${pkgs.inotify-tools}/bin/inotifywait";
  filewatch = (
    # `echo` and `true` are bash builtins
    pkgs.writeShellScriptBin "filewatch"
    ''
      if [[ "$#" -lt 2 ]];
      then
        echo "Missing parameter. Call like: $0 COMMAND FILES_OR_DIRS..." >&2
        exit 1
      fi

      command="$1"

      shift

      inotify_output=""
      inotify_retval=0

      while [[ "$inotify_retval" -eq 0 ]]
      do
        "$SHELL" -c "$command"
        inotify_output=$(${inotifywait} "$@" -e modify,create,delete,unmount,move,attrib 2>&1)
        inotify_retval=$?
      done

      echo 1>&2
      echo inotifywait failed with output: 1>&2
      echo "$inotify_output" 1>&2
      exit $inotify_retval
    ''
  );
in
  filewatch
