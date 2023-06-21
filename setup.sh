#!/bin/bash

set -eu

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    sudo apt update
    sudo apt upgrade
    sudo apt install -y build-essential procps curl file git gcc zlib1g-dev
    sudo apt autoremove
fi

# set dotflies
DOTPATH=$HOME/dotfiles

if [ ! -d "$DOTPATH" ]; then
    git clone https://github.com/nashirox/dotfiles.git "$DOTPATH"
else
    echo "$DOTPATH already exists. Updating..."
    cd "$DOTPATH"
    git stash
    git checkout master
    git pull origin master
    echo
fi

cd "$DOTPATH"

# install Homebrew
if !(type brew > /dev/null 2>&1); then
    yes | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $HOME/.profile
    echo 'eval "$(rbenv init - bash)"' >> $HOME/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    . $HOME/.profile
    echo
fi

# update Homebrew
brew update && brew outdated && brew upgrade && brew cleanup

# bundle for common
brew bundle

# bundle for macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew bundle --file $DOTPATH/macos/Brewfile
fi

# install latest Ruby
if !(type ruby > /dev/null 2>&1); then
    asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
    asdf install ruby latest
    asdf global ruby $(asdf latest ruby)
    echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> $HOME/.profile
    echo -e "\n. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" >> $HOME/.profile
    . $HOME/.profile
fi

# install latest Python
if !(type python > /dev/null 2>&1); then
    asdf plugin-add python https://github.com/asdf-vm/asdf-python.git
    asdf install python 3.10.4
    asdf global python 3.10.4
    echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> $HOME/.profile
    echo -e "\n. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" >> $HOME/.profile
    . $HOME/.profile
fi

# install latest node
if !(type node > /dev/null 2>&1); then
    asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
    asdf install nodejs latest
    asdf global nodejs $(asdf latest nodejs)
    echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> $HOME/.profile
    echo -e "\n. $(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" >> $HOME/.profile
    . $HOME/.profile
fi

# restore config
if [[ "$OSTYPE" == "darwin"* ]]; then
    mackup restore
fi

echo "Setup finished!"
