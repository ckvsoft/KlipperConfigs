#!/bin/bash

rp=$(realpath $1)

echo "watching $rp"

inotifywait -m -r $rp | while read DIRECTORY EVENT FILE; do
    echo "$EVENT $FILE"
    case $EVENT in
        MOVED_TO*)
            echo "$DIRECTORY / $FILE"
            ;;
        DELETE*)
            echo "$DIRECTORY / $FILE"
            ;;
    esac
done
