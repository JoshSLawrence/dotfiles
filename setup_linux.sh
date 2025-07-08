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
        fortune-mod

    # Install asdf version 0.18.0
    wget -O asdf.tar.gz https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-v0.18.0-linux-amd64.tar.gz
    tar -xzvf asdf.tar.gz
    chmod +x asdf
    mv asdf $HOME/.local/bin
    rm asdf.tar.gz

    # Install asdf plugins
    asdf plugin add kubectl https://github.com/asdf-community/asdf-kubectl.git
    asdf plugin add terraform https://github.com/asdf-community/asdf-hashicorp.git
    asdf plugin add opentofu https://github.com/virtualroot/asdf-opentofu.git

    # Install asdf tools (uses the .tools-versions found in dotfiles repo)
    run asdf install

    # Install Krew (kubectl extension)
    (
      set -x; cd "$(mktemp -d)" &&
      OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
      ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
      KREW="krew-${OS}_${ARCH}" &&
      curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
      tar zxvf "${KREW}.tar.gz" &&
      ./"${KREW}" install krew
    )

    # Install K9s cli
    mkdir k9s
    cd k9s
    wget https://github.com/derailed/k9s/releases/download/v0.50.7/k9s_Linux_amd64.tar.gz
    tar -xzvf k9s_Linux_amd64.tar.gz
    chmod +x k9s
    mv k9s "$HOME/.local/bin"
    cd -
    rm -rf k9s

    # Install oh-my-posh
    curl -s https://ohmyposh.dev/install.sh | bash -sk

    # Install fzf
    # NOTE: This is an optional dep for zoxide and is required for the 'kc'
    # alias in .exports pulled in via .zshrc
    wget https://github.com/junegunn/fzf/releases/download/v0.61.0/fzf-0.61.0-linux_amd64.tar.gz
    sudo tar -C /usr/local/bin -xzf fzf-0.61.0-linux_amd64.tar.gz
    rm fzf-0.61.0-linux_amd64.tar.gz

    # Install zoxide
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

    # Install JetBrains Mono Nerd Font
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip
    sudo unzip JetBrainsMono.zip -d /usr/local/share/fonts/JetBrainsMono.zip
    sudo fc-cache -f -v
    rm JetBrainsMono.zip

    # Install latest version of LazyGit
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
    wget -O lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar -xf lazygit.tar.gz lazygit
    install lazygit -D -t $HOME/.local/bin
    rm lazygit.tar.gz
    rm lazygit

    # Install Azure cli
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

    # Install dotnet latest (9 at the time of commit)
    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
    chmod +x ./dotnet-install.sh
    ./dotnet-install.sh --version latest
    rm dotnet-install.sh

    # Install PowerShell 7
    # from: https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.5
    sudo apt-get update
    sudo apt-get install -y wget apt-transport-https software-properties-common
    source /etc/os-release
    wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt-get update && sudo apt-get install -y powershell

    # Install node v22.14.0
    wget https://nodejs.org/dist/v22.14.0/node-v22.14.0-linux-x64.tar.xz
    tar -xvf node-v22.14.0-linux-x64.tar.xz
    sudo cp node-v22.14.0-linux-x64/bin /usr -r
    sudo cp node-v22.14.0-linux-x64/lib /usr -r
    sudo cp node-v22.14.0-linux-x64/share /usr -r
    sudo cp node-v22.14.0-linux-x64/include /usr -r
    rm node-v22.14.0-linux-x64.tar.xz
    rm -rf node-v22.14.0-linux-x64

    # Npm install now that node is present
    sudo npm install -g cowsay

    # Install neovim v0.11.0
    wget https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.tar.gz
    tar -xzvf nvim-linux-x86_64.tar.gz
    cp nvim-linux-x86_64/. $HOME/.local/. -r
    rm nvim-linux-x86_64.tar.gz
    rm -rf nvim-linux-x86_64

    # Install go programming language
    wget https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.24.2.linux-amd64.tar.gz
    rm go1.24.2.linux-amd64.tar.gz

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
    echo -e "${GREEN}Done${NOCOLOR}"

    # Check tracked configs before wrapping up
    detect_untracked "$LOCAL_CONFIG" "$DOTFILES_CONFIG"

    # Done!
    echo -e "${GREEN}[Complete]${NOCOLOR} configuration syncd.\n"
    echo -e "Don't forget to logout to change shells or source your ~/.zshrc!"
else
    echo "${RED}[ERROR]${NOCOLOR} This setup script is for Linux only!"
fi
