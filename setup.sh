#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#           _           _       _                                                 #
#          | |         | |     | |                                                #
#          | | ___  ___| |__   | |     __ ___      ___ __ ___ _ __   ___ ___      #
#      _   | |/ _ \/ __| '_ \  | |    / _` \ \ /\ / / '__/ _ \ '_ \ / __/ _ \     #
#     | |__| | (_) \__ \ | | | | |___| (_| |\ V  V /| | |  __/ | | | (_|  __/     #
#      \____/ \___/|___/_| |_| |______\__,_| \_/\_/ |_|  \___|_| |_|\___\___|     #
#                            _       _    __ _ _                                  #
#                           | |     | |  / _(_) |                                 #
#                         __| | ___ | |_| |_ _| | ___  ___                        #
#                        / _` |/ _ \| __|  _| | |/ _ \/ __|                       #
#                       | (_| | (_) | |_| | | | |  __/\__ \                       #
#                        \__,_|\___/ \__|_| |_|_|\___||___/                       #
#                                                                                 #
#                                                                                 #
#                             Josh Lawrence - dotfiles                            #
#                                                                                 #
#                        - https://github.com/JoshSLawrence                       #
#                        - josh@joshlawrence.dev                                  #
#                                                                                 #
#                                                                                 #
#                You can die anytime, but living takes true courage               #
#                                                                                 #
#                                                    - Kenshin Himura             #
#                                                                                 #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


cd "$(dirname "$0")"

local_config_dir="$HOME/.config"
remote_config_dir="./config"
local_dirs=$(find $local_config_dir -mindepth 1 -maxdepth 1 -type d)
remote_dirs=$(find "./config" -mindepth 1 -maxdepth 1 -type d)
remote_root_dotfiles=$(find "./root" -mindepth 1 -maxdepth 1)

# Colors for string formatting
Color_Off='\033[0m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Red='\033[0;31m'



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#         A bunch of helper functions - search for "Lets get shit installed"      #
#                          to see main execution area                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


strip_dir_name(){
    # Dont add this repo to scope
    if [ $1 == "./.git" ]; then
        return
    fi

    echo "$(basename "$1")"
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


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                          Lets get shit installed                                #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

git submodule init
git submodule update

OS=$(uname)

if [ $OS == "Linux" ]; then
    sudo apt update -y
    sudo apt upgrade -y

    # General dependencies
    sudo apt install curl unzip ripgrep python3.12-venv zsh zsh-syntax-highlighting gcc

    # oh-my-posh
    curl -s https://ohmyposh.dev/install.sh | bash -sk

    # Install CommitMono Nerd Font
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip
    sudo unzip JetBrainsMono.zip -d /usr/local/share/fonts/JetBrainsMono.zip
    sudo fc-cache -f -v
    rm JetBrainsMono.zip

    # Install LazyGit
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar -xf lazygit.tar.gz lazygit
    sudo install lazygit -D -t /usr/local/bin/
    rm lazygit.tar.gz
    rm lazygit

    # Install terraform
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform

    # Install Azure cli
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

    # Change default shell to zsh
    echo "Changing default shell to zsh, prompting for password..."
    chsh -s /bin/zsh

    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
    echo 'eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/catppuccin_custom.omp.json)"' >> "$HOME/.zshrc"
    echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
else
    echo "$Red[ERROR]$Color_Off This setup script is for Linux only!"
fi

# Collect local and remote config dir names
# remote_names=$(fetch_dirs "${remote_dirs}")
# local_names=$(fetch_dirs "${local_dirs}")
# remote_root_dotfile_names=$(fetch_dirs "${remote_root_dotfiles}")

# Install root dotfiles
# for dotfile in $remote_root_dotfile_names; do
#     rm -rf "$HOME/.$dotfile"
#
#     if [ $dotfile == "tmux" ]; then
#         rsync -rvc "./root/$dotfile/" "$HOME/.$dotfile"
#     else
#         rsync -rvc "./root/$dotfile" "$HOME/.$dotfile"
#     fi
#
#     # Check for bad exit code from copy
#     if [ $? -ne 0 ]; then
#         echo -e "\n$Red[Failed]$Color_Off local '.$dotfile' sync.\n"
#         exit
#     fi
#
#     echo -e "\n$Green[SUCCESS]$Color_Off local '.$dotfile' is in sync with remote.\n"
# done
#
# # Provision config
# for name in $remote_names; do
#     rm -rf "$local_config_dir/$name"
#     rsync -rvc --delete "$remote_config_dir/$name/" "$local_config_dir/$name/"
#
#     # Check for bad exit code by rsync
#     if [ $? -ne 0 ]; then
#         echo -e "\n$Red[Failed]$Color_Off local '.config/$name' sync.\n"
#         exit
#     fi
#
#     echo -e "\n$Green[SUCCESS]$Color_Off local '.config/$name' is in sync with remote.\n"
# done
#
# # Show local dirs not present in remote
# detect_untracked "${local_names}" "${remote_names}"

# Done!
echo -e "\n$Green[Complete]$Color_Off configuration syncd."
echo -e "\nDon't forget to logout to change shells or source your ~/.zshrc!"
