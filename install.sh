#!/bin/bash

# Configure OSX
# Credit:
# https://github.com/junegunn/dotfiles/blob/master/install
# https://github.com/gcuisinier/MacConfig

osascript -e 'tell application "System Preferences" to quit'
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Xcode command lines tools cli
xcode-select --install
sleep 1
osascript <<EOD
  tell application "System Events"
    tell process "Install Command Line Developer Tools"
      keystroke return
      click button "Agree" of window "License Agreement"
    end tell
  end tell
EOD

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Disable Download quarantine
defaults write com.apple.LaunchServices LSQuarantine -bool NO

# Configure Touchpad
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Graphical App install from Home-brew cask
brew install flux
brew install --cask bettertouchtool path-finder
brew install --cask google-chrome-canary google-chrome firefox
brew install --cask caffeine
brew install --cask keka
brew install --cask whatsapp
brew install --cask skitch
brew install --cask kap
brew install --cask qbserve
brew install --cask 1password
brew install --cask google-drive
brew install --cask visual-studio-code
brew install --cask pdfsam-basic
brew install --cask slack
brew install --cask intellij-idea
brew install --cask colorsnapper
brew install --cask spectacle
brew install --cask alacritty
brew install --cask karabiner-elements
brew install --cask maccy
brew install --cask macfuse
brew install --cask nightowl

#less often
brew install --cask vlc
brew install --cask spotify

#Install Java JDK
brew install --cask java6
brew install --cask java7
brew install --cask homebrew/cask-versions/adoptopenjdk8
brew install --cask	adoptopenjdk11

brew tap homebrew/cask-fonts
brew install --cask font-fira-code

# Brew package
brew install mas mkcert nss xquartz

# Install zsh
# brew install zsh shellcheck autojump
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k

# mkdir -p $HOME/.shellrc/zshrc.d/

# Install App from Mac App Store

# Affinity Photo
# mas install 824183456
# Affinity Designer
# Mas install 824171161

# Configure Visual Studio Code
code --install-extension dbaeumer.vscode-eslint
code --install-extension msjsdiag.debugger-for-chrome
code --install-extension github.github-vscode-theme
code --install-extension graphql.vscode-graphql
code --install-extension wmaurer.vscode-jumpy
code --install-extension ms-vsliveshare.vsliveshare
code --install-extension davidanson.vscode-markdownlint
code --install-extension pkief.material-icon-theme
code --install-extension christian-kohler.path-intellisense
code --install-extension esbenp.prettier-vscode
code --install-extension prisma.prisma
code --install-extension vscodevim.vim
code --install-extension nrwl.angular-console

# Install GraphViz
brew install libtool
brew link libtool
brew install graphviz
brew link --overwrite graphviz

#Install Frontend Development tools
brew install yarn --ignore-dependencies
npm install -g typescript
npm install -g ts-node

npm install -g tldr

brew install --cask keepingyouawake \
	mat visualvm mactex

# dev tools
brew install fzf
$(brew --prefix)/opt/fzf/install

brew install \
	fd ag ripgrep bat git-delta cmake cmus \
	imagemagick gnupg \
	tree wget jq \
	pyenv xz python python@3.9 \
	reattach-to-user-namespace bash bash-completion@2 tmux \
	translate-shell libpq exa jenv maven lua luajit-openresty \
	perl krb5 luv tree-sitter berkeley-db libevent mpdecimal \
	readline unibilium ca-certificates msgpack utf8proc libtermkey ncurses vim neovim\
	libuv ruby xz libvterm openssl@1.1 sqlite gdbm libyaml libffi pcre the_silver_searcher \
	gettext pcre2 ngrep z ffmpeg youtube-dl cocoapods awscli

# this is needed for UtilSnips
python3 -m pip install --user --upgrade pynvim

# setup neovim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# git-prompt
if [ ! -e ~/.git-prompt.sh ]; then
  curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh
fi

#git clone https://github.com/faruzzy/dotfiles
# for loop for adding symbolic link to the HOME folder
#tmux source-file ~/.tmux.conf
#./install-vim
