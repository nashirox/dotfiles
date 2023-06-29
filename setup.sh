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


if !(type asdf > /dev/null 2>&1); then
fi

# install latest Ruby
if !(type ruby > /dev/null 2>&1); then
    echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bashrc
    echo -e "\n. \"$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash\"" >> ~/.bashrc
    . $HOME/.bashrc

    asdf plugin add ruby
    LATEST_RUBY_VERSION=$(asdf list-all ruby | tail -1)
    asdf install ruby $LATEST_RUBY_VERSION
    asdf global ruby $LATEST_RUBY_VERSION
fi

# install latest Python
if !(type python > /dev/null 2>&1); then
    asdf plugin-add python https://github.com/danhper/asdf-python.git
    LATEST_PYTHON_VERSION=$(asdf list-all python | tail -1)
    asdf install python $LATEST_PYTHON_VERSION
    asdf global python $LATEST_PYTHON_VERSION
fi

# install latest node
if !(type node > /dev/null 2>&1); then
    asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    
    # Import the Node.js release team's OpenPGP keys to main keyring
    bash $HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring
    
    LATEST_NODEJS_VERSION=$(asdf list-all nodejs | grep -v - | tail -1)
    asdf install nodejs $LATEST_NODEJS_VERSION
    asdf global nodejs $LATEST_NODEJS_VERSION
fi

# restore config
if [[ "$OSTYPE" == "darwin"* ]]; then
    mackup restore
fi

echo "Setup finished!"
