#!/bin/bash


######################################################################
### Please set the paths accordingly. In case you don't have all  ###
### the listed folders, just keep that line commented out.        ###
#####################################################################
### Path to your config folder you want to backup
config_folder=~/ckvsoft_config/
printer_type=$(head -n 1 ~/printer_data/config/.version)

### Path to your Klipper folder, by default that is '~/klipper'
klipper_folder=~/klipper

### Path to your Moonraker folder, by default that is '~/moonraker'
moonraker_folder=~/moonraker

### Path to your Mainsail folder, by default that is '~/mainsail'
mainsail_folder=~/mainsail

### Path to your Fluidd folder, by default that is '~/fluidd'
#fluidd_folder=~/fluidd

#####################################################################
#####################################################################


#####################################################################
################ !!! DO NOT EDIT BELOW THIS LINE !!! ################
#####################################################################

new_tag(){
    VERSION=`git describe --abbrev=0 --tags 2>/dev/null`

    if [ -z $VERSION ];then
        NEW_TAG="0.0.1"
        echo "No tag present."
        echo "Creating tag: $NEW_TAG"
        git tag $NEW_TAG
        git push --tags
        echo "Tag created and pushed: $NEW_TAG"
        exit 0;
    fi

    #replace . with space so can split into an array
    VERSION_BITS=(${VERSION//./ })

    #get number parts and increase last one by 1
    VNUM1=${VERSION_BITS[0]}
    VNUM2=${VERSION_BITS[1]}
    VNUM3=${VERSION_BITS[2]}
    VNUM3=$((VNUM3+1))

    #create new tag
    NEW_TAG="${VNUM1}.${VNUM2}.${VNUM3}"

    #get current hash and see if it already has a tag
    GIT_COMMIT=`git rev-parse HEAD`
    CURRENT_COMMIT_TAG=`git describe --contains $GIT_COMMIT 2>/dev/null`

    #only tag if no tag already (would be better if the git describe command above could have a silent option)
    if [ -z "$CURRENT_COMMIT_TAG" ]; then
        echo "Updating $VERSION to $NEW_TAG"
        git tag $NEW_TAG
        git push --tags
        echo "Tag created and pushed: $NEW_TAG"
    else
        echo "This commit is already tagged as: $CURRENT_COMMIT_TAG"
    fi
}

grab_version(){
  if [ ! -z "$klipper_folder" ]; then
    echo -n "Getting klipper version="
    cd "$klipper_folder"
    klipper_commit=$(git describe --tags)
    m1="Klipper on commit: $klipper_commit"
    echo $klipper_commit
    cd ..
  fi
  if [ ! -z "$moonraker_folder" ]; then
    echo -n "Getting moonraker version="
    cd "$moonraker_folder"
    moonraker_commit=$(git describe --tags)
    m2="Moonraker on commit: $moonraker_commit"
    echo $moonraker_commit
    cd ..
  fi
  if [ ! -z "$mainsail_folder" ]; then
    echo -n "Getting mainsail version="
    mainsail_ver=$(head -n 1 $mainsail_folder/.version)
    m3="Mainsail version: $mainsail_ver"
    echo $mainsail_ver
  fi
  if [ ! -z "$fluidd_folder" ]; then
    echo -n "Getting fluidd version="
    fluidd_ver=$(head -n 1 $fluidd_folder/.version)
    m4="Fluidd version: $fluidd_ver"
    echo $fluidd_ver
  fi
}

push_config(){
  ionice -c 3 rsync --update --delete-after --exclude 'printer-*' -raz ~/printer_data/config/ ~/ckvsoft_config/$printer_type
  cd $config_folder
  echo Pushing updates
  git pull -v
  git add . -v
  current_date=$(date +"%d-%m-%Y %T")
  git commit -m "Backup for $printer_type triggered on $current_date" -m "$m1" -m "$m2" -m "$m3" -m "$m4"
  git push
  echo Tagging updates
  new_tag
  ionice -c 3 rsync --update --delete-after -raz ~/ckvsoft_config/$printer_type ~/printer_data/config/
}

grab_version
push_config
