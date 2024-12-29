#!/bin/bash

cd "$(dirname "$0")"

local_config_dir="$HOME/.config"
remote_config_dir="./config"
local_dirs=$(find $local_config_dir -mindepth 1 -maxdepth 1 -type d)
remote_dirs=$(find "./config" -mindepth 1 -maxdepth 1 -type d)
remote_root_dotfiles=$(find "./root" -mindepth 1 -maxdepth 1 -type f)

# Colors for string formatting
Color_Off='\033[0m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Red='\033[0;31m'

strip_dir_name(){
    # Store default IFS value for restore later
    old_IFS=$IFS

    # Dont add this repo to scope
    if [ $1 == "./.git" ]; then
        return
    fi

    # Bash version of a string split
    IFS='/'
    read -ra name <<< $1

    # Restore IFS back to avoid side effects
    IFS=$old_IFS

    # Last element should be target dir name
    echo "${name[-1]}"
}

fetch_dirs(){
    names=()

    for dir in $1; do
        name=$(strip_dir_name $dir)
        names+=("${name}")
    done

    echo "${names[@]}"
}

detect_untracked(){
    for i in $1; do
        if [ $i == "nvim" ]; then
            continue
        fi

        tracked=false

        for e in $2; do
            if [ $i == $e ]; then
                tracked=true
                break
            fi
        done

        if [ $tracked == false ]; then
        echo -e "$Yellow[WARNING]$Color_Off local config '$i' is not tracked"
        fi
    done
}


# Collect local and remote config dir names
remote_names=$(fetch_dirs "${remote_dirs}")
local_names=$(fetch_dirs "${local_dirs}")
remote_root_dotfile_names=$(fetch_dirs "${remote_root_dotfiles}")

# Install root dotfiles
for dotfile in $remote_root_dotfile_names; do
    rm -f "$HOME/.$dotfile"
    cp "./root/$dotfile" "$HOME/.$dotfile"

    # Check for bad exit code from copy
    if [ $? -ne 0 ]; then
        echo -e "$Red[Failed]$Color_Off local '.$dotfile' sync."
        exit
    fi

    echo -e "$Green[SUCCESS]$Color_Off local '.$dotfile' is in sync with remote."
done

# Provision config
for name in $remote_names; do
    rm -rf "$local_config_dir/$name"
    rsync -rvc --delete --quiet "$remote_config_dir/$name/" "$local_config_dir/$name/"

    # Check for bad exit code by rsync
    if [ $? -ne 0 ]; then
        echo -e "$Red[Failed]$Color_Off local '.config/$name' sync."
        exit
    fi

    echo -e "$Green[SUCCESS]$Color_Off local '.config/$name' is in sync with remote."
done

# Show local dirs not present in remote
detect_untracked "${local_names}" "${remote_names}"

# Done!
echo -e "\n$Green[Complete]$Color_Off configuration syncd"
