#!/bin/bash

rp=$(realpath "$1")
update="$(dirname "$(realpath "$0")")/update.sh"

echo "watching $rp"

inotifywait -q -m -r -e moved_to,delete "$rp" | while read DIRECTORY EVENT FILE; do
    case $EVENT in
        MOVED_TO*)
            echo "Moved To $DIRECTORY / $FILE"
            "$update"
            ;;
        DELETE*)
            echo "Delete $DIRECTORY / $FILE"
            ;;
    esac
done
