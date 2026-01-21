#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#         _           _       _                                               #
#        | |         | |     | |                                              #
#        | | ___  ___| |__   | |     __ ___      ___ __ ___ _ __   ___ ___    #
#    _   | |/ _ \/ __| '_ \  | |    / _` \ \ /\ / / '__/ _ \ '_ \ / __/ _ \   #
#   | |__| | (_) \__ \ | | | | |___| (_| |\ V  V /| | |  __/ | | | (_|  __/   #
#    \____/ \___/|___/_| |_| |______\__,_| \_/\_/ |_|  \___|_| |_|\___\___|   #
#                          _       _    __ _ _                                #
#                         | |     | |  / _(_) |                               #
#                       __| | ___ | |_| |_ _| | ___  ___                      #
#                      / _` |/ _ \| __|  _| | |/ _ \/ __|                     #
#                     | (_| | (_) | |_| | | | |  __/\__ \                     #
#                      \__,_|\___/ \__|_| |_|_|\___||___/                     #
#                                                                             #
#                                                                             #
#                           Josh Lawrence - dotfiles                          #
#                                                                             #
#                      - https://github.com/JoshSLawrence                     #
#                      - josh@joshlawrence.dev                                #
#                                                                             #
#                                                                             #
#               You can die anytime, but living takes true courage            #
#                                                                             #
#                                           - Kenshin Himura                  #
#                                                                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Ensure we start outfrom the root of the dotfiles repo directory
cd "$(dirname "$0")"
WORKING_DIR=$(pwd)

mkdir -p $HOME/.config
mkdir -p $HOME/.local/bin

# Colors for string formatting
NOCOLOR='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#      A bunch of helper functions - search for "Lets get shit installed"     #
#                          to see main execution area                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

link_config() {
    echo -e "${YELLOW}\nLinking configuration to the local system${NOCOLOR}\n"

    LOCAL_CONFIG=$(find "$HOME/.config" -mindepth 1 -maxdepth 1)
    DOTFILES_CONFIG=$(find "$WORKING_DIR/linux/.config" -mindepth 1 -maxdepth 1)
    DOTFILES_ROOT=$(find "$WORKING_DIR/linux" -mindepth 1 -maxdepth 1)

    # Remove root config in $HOME
    # Skipping over the .config directory
    for config in $DOTFILES_ROOT; do
        if [ $(basename $config) = ".config" ]; then
            continue
        fi
	    rm -rf "$HOME/$(basename $config)"
        echo -e "${RED}[REMOVED]${NOCOLOR} $HOME/$(basename $config)"
    done

    # Remove config in $HOME/.config
    for config in $DOTFILES_CONFIG; do
	    rm -rf "$HOME/.config/$(basename $config)"
        echo -e "${RED}[REMOVED]${NOCOLOR} $HOME/.config/$(basename $config)"
    done

    # Adds bit of separationg between console logged removals/links
    echo

    # Sym link root config for $HOME
    # Skipping over the .config directory
    for config in $DOTFILES_ROOT; do
        if [ $(basename $config) = ".config" ]; then
            continue
        fi

        ln -s $config "$HOME/$(basename $config)"

        if [ $? = 0 ]; then
             echo -e "${GREEN}[LINKED]${NOCOLOR} "$HOME/$(basename $config)" -> $config"
        else
             echo -e "${RED}[LINK FAILED]${NOCOLOR} "$HOME/$(basename $config)" -> $config"
        fi
    done

    # Sym link config for $HOME/.config
    for config in $DOTFILES_CONFIG; do
        ln -s $config "$HOME/.config/$(basename $config)"

        if [ $? = 0 ]; then
             echo -e "${GREEN}[LINKED]${NOCOLOR} "$HOME/.config/$(basename $config)" -> $config"
        else
             echo -e "${RED}[LINK FAILED]${NOCOLOR} "$HOME/.config/$(basename $config)" -> $config"
        fi
    done

    echo -e "${GREEN}\nLinking complete${NOCOLOR}\n"
}

detect_untracked() {
    # arg $1 is a list of directories on the local system
    # arg $2 is a list of directories in the dotfiles repo
    # Iterate through $1 and compare against $2
    # If a dir in $1 is not present in $2, these means it is not 
    # in the dotfiles repo, warn the user if they wish it to be in repo
    echo -e "${YELLOW}Checking for untracked configuration in $HOME/.config${NOCOLOR}\n"

    LOCAL_CONFIG=$(find "$HOME/.config" -mindepth 1 -maxdepth 1)
    DOTFILES_CONFIG=$(find "$WORKING_DIR/linux/.config" -mindepth 1 -maxdepth 1)
    CONFIGNORE="./.confignore"

    all_tracked=true
    
    # Read .confignore into an array
    mapfile -t confignore < $CONFIGNORE

    for i in $LOCAL_CONFIG; do
        tracked=false

        for e in $DOTFILES_CONFIG; do
            if [ "$(basename $i)" = "$(basename $e)" ]; then
                tracked=true
                break
            fi
        done

        for w in "${confignore[@]}"; do
            if [ "$(basename $i)" = "$(basename $w)" ]; then
                tracked=true
                break
            fi
        done

        if [ $tracked = false ]; then
            all_tracked=false
            echo -e "${YELLOW}[WARNING]${NOCOLOR} local config ${GREEN}'$i'${NOCOLOR} ${YELLOW}is not tracked${NOCOLOR}"
        fi
    done
    
    if [ $all_tracked = false ]; then
        echo -e "\nTo suppress these warnings, add the directories to the ${GREEN}.confignore${NOCOLOR} file in repo."
        echo -e "Otherwise, commit the missing configuration to the repo.\n"
    else
        echo -e "${GREEN}All configuration in the local system is being tracked.${NOCOLOR}\n"
    fi
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                        Lets get shit installed                              #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

OS=$(uname)

if [ $OS == "Linux" ]; then
    git submodule init
    git submodule update

    # If the arg 'full' is not passed, sync dotfiles only (due to the exit)
    # So, a consumer should pass the arg 'full' for this entire script to run
    if [ "$1" != "full" ]; then
        link_config
        detect_untracked 
        echo -e "${GREEN}[Complete]${NOCOLOR} configuration syncd.\n"
        exit
    fi

    sudo apt update -y
    sudo apt upgrade -y

    # General dependencies
    sudo apt install curl unzip ripgrep python3.12-venv \
        zsh zsh-syntax-highlighting gcc libice6 libsm6 xclip fd-find make \
        fortune-mod apt-transport-https -y

    # Install mise
    curl https://mise.run | sh

    # Install JetBrains Mono Nerd Font
    if [ ! -d "/usr/local/share/fonts/JetBrainsMono" ]; then
      wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip
      sudo unzip JetBrainsMono.zip -d /usr/local/share/fonts/JetBrainsMono
      sudo fc-cache -f -v
      rm JetBrainsMono.zip
    else
        echo -e "\n${YELLOW}JetBrains Mono Nerd Font already installed, skipping.${NOCOLOR}\n"
    fi

    # Install dotnet latest (9 at the time of commit)
    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
    chmod +x ./dotnet-install.sh
    ./dotnet-install.sh --channel LTS
    rm dotnet-install.sh

    # Configure git credential manager (WSL)
    git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
    git config --global credential.https://dev.azure.com.useHttpPath true
    git config --global user.name "Josh Lawrence"
    git config --global user.email "josh@joshlawrence.dev"

    # Symlink config directories to local system
    link_config

    # Change default shell to zsh
    echo "Changing default shell to zsh, prompting for password..."
    chsh -s /bin/zsh

    # Check tracked configs before wrapping up
    detect_untracked "$LOCAL_CONFIG" "$DOTFILES_CONFIG"

    # Done!
    echo -e "${GREEN}[Complete]${NOCOLOR} configuration syncd.\n"
    echo -e "Don't forget to logout to change shells or source your ~/.zshrc!"
elif [ $OS == "Darwin" ]; then
    git submodule init
    git submodule update

    # If the arg 'full' is not passed, sync dotfiles only (due to the exit)
    # So, a consumer should pass the arg 'full' for this entire script to run
    if [ "$1" != "full" ]; then
        link_config
        detect_untracked 
        echo -e "${GREEN}[Complete]${NOCOLOR} configuration syncd.\n"
        exit
    fi

    brew update
    brew upgrade

    # General dependencies
    brew install ripgrep python@3.14 \
        zsh-syntax-highlighting \
        fortune 

    # Install mise
    curl https://mise.run | sh

    # Configure git
    git config --global user.name "Josh Lawrence"
    git config --global user.email "josh@joshlawrence.dev"

    # Symlink config directories to local system
    link_config

    # Install remaining tools (must run after link_config)
    mise install

    # Check tracked configs before wrapping up
    detect_untracked "$LOCAL_CONFIG" "$DOTFILES_CONFIG"

    # Done!
    echo -e "${GREEN}[Complete]${NOCOLOR} configuration syncd.\n"
else
    echo -e "${RED}[ERROR]${NOCOLOR} This setup script is for Linux only!"
fi
