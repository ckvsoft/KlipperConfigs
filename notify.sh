#!/bin/bash

rp=$(realpath $1)

echo "watching $rp"

inotifywait -q -m -r $rp | while read DIRECTORY EVENT FILE; do
#    echo "$EVENT $FILE"
    case $EVENT in
        MOVED_TO*)
            echo "Moved To $DIRECTORY / $FILE"
            ~/ckvsoft_config/update.sh
            ;;
        DELETE*)
            echo "Delete $DIRECTORY / $FILE"
            ;;
    esac
done
