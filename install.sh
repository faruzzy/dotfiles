#!/usr/bin/env bash

# macOS Development Environment Setup Script
# Automated setup for development tools, applications, and dotfiles
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly LOG_FILE="$HOME/install.log"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }

# Utility functions
command_exists() { command -v "$1" &> /dev/null; }

ask_yes_no() {
    local prompt="$1"
    local default="${2:-}"

    while true; do
        if [[ "$default" == "y" ]]; then
            read -rp "$prompt [Y/n]: " response
            response=${response:-y}
        elif [[ "$default" == "n" ]]; then
            read -rp "$prompt [y/N]: " response
            response=${response:-n}
        else
            read -rp "$prompt [y/n]: " response
        fi

        case "${response,,}" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

# System preparation
prepare_system() {
    log_info "Preparing system..."

    # Close System Preferences
    osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

    # Request sudo access
    sudo -v

    # Keep sudo alive
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &

    log_success "System prepared"
}

# Xcode Command Line Tools
install_xcode_tools() {
    log_info "Checking Xcode Command Line Tools..."

    if command_exists xcode-select; then
        log_success "Command Line Tools already installed"
        return 0
    fi

    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install

    # Wait for installation to complete
    # NOTE: The automated 'Agree' click from the original script is often unreliable/not recommended.
    # We will wait for the tool to be available, or the user to manually agree/install.
    log_warning "Please follow the on-screen prompts to install Command Line Tools."
    until command_exists xcode-select; do
        sleep 5
    done

    log_success "Xcode Command Line Tools installed"
}

# Homebrew installation and management
install_homebrew() {
    log_info "Checking Homebrew installation..."

    if command_exists brew; then
        log_success "Homebrew already installed"

        if ask_yes_no "Update and upgrade Homebrew packages?" "y"; then
            log_info "Updating Homebrew..."
            brew update
            brew upgrade
            log_success "Homebrew updated"
        fi
        return 0
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -d "/opt/homebrew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    log_success "Homebrew installed"
}

# Install development tools (FORMULAS)
install_dev_tools() {
    log_info "Installing development tools (formulas)..."

    local dev_tools=(
        # Build tools and dependencies
        ninja cmake gettext curl
        # Search and file tools
        fd ag ripgrep bat fzf the_silver_searcher # Added the_silver_searcher
        # Git tools
        gh git-delta tig
        # System tools
        tree wget jq htop
        # Programming languages and tools
        pyenv python python@3.9 xz # Added xz
        lua luajit-openresty perl
        # Shell and terminal
        zsh shellcheck autojump tmux zoxide # Added tmux, zsh, shellcheck, autojump
        reattach-to-user-namespace bash bash-completion@2 # Added reattach-to-user-namespace, bash, bash-completion@2
        # Database and networking
        libpq krb5 berkeley-db libevent mpdecimal openssl@1.1 sqlite gdbm libyaml libffi pcre pcre2 # Added database/networking/library deps
        # Other utilities
        imagemagick gnupg gnu-sed translate-shell
        eza jenv maven
        luv tree-sitter libtermkey ncurses vim libuv libvterm unibilium ca-certificates msgpack utf8proc # Added Neovim/Vim-related deps
        ngrep z ffmpeg youtube-dl cocoapods awscli http-server allure # Added networking/utility tools
        mkcert nss xquartz # Added miscellaneous utilities
        cmus # Added console media player
        deno # Added deno from original script's end
    )

    for tool in "${dev_tools[@]}"; do
        if ! brew list "$tool" &>/dev/null; then
            log_info "Installing $tool..."
            # Use --HEAD for neovim as in the original script
            if [[ "$tool" == "neovim" ]]; then
                brew install --HEAD neovim || log_warning "Failed to install $tool"
            else
                brew install "$tool" || log_warning "Failed to install $tool"
            fi
        fi
    done

    # Special handling for specific tools
    brew install libtool && brew link libtool || log_warning "Failed to link libtool"
    brew install graphviz && brew link --overwrite graphviz || log_warning "Failed to link graphviz"
    brew install yarn --ignore-dependencies || log_warning "Failed to install yarn"

    # Install fzf shell integration
    if command_exists fzf; then
        "$(brew --prefix)"/opt/fzf/install --all --no-bash --no-fish || log_warning "Failed to install fzf shell integration"
    fi

    log_success "Development tools installed"
}

# Install GUI applications (CASKS)
install_gui_apps() {
    log_info "Installing GUI applications (casks)..."

    # Window management and productivity
    local productivity_apps=(
        rectangle spectacle alt-tab
        bettertouchtool karabiner-elements
        caffeine keepingyouawake
        maccy
        path-finder # Added path-finder
    )

    # Development tools
    local dev_apps=(
        visual-studio-code
        alacritty ghostty
        intellij-idea
        viz
    )

    # Media and utilities
    local utility_apps=(
        app-cleaner keka
        skitch kap
        qbserve pdfsam-basic
        colorsnapper
        vlc spotify
        visualvm # Added visualvm
    )

    # Browsers
    local browsers=(
        firefox@developer-edition
        google-chrome-canary
        google-chrome
        firefox
    )

    # Other apps
    local other_apps=(
        whatsapp
        google-drive
        macfuse
        nightowl
    )

    # Install all cask applications
    local all_apps=("${productivity_apps[@]}" "${dev_apps[@]}" "${utility_apps[@]}" "${browsers[@]}" "${other_apps[@]}")

    for app in "${all_apps[@]}"; do
        if ! brew list --cask "$app" &>/dev/null; then
            log_info "Installing $app..."
            brew install --cask "$app" || log_warning "Failed to install $app"
        fi
    done

    log_success "GUI applications installed"
}

# Install fonts
# install_fonts() {
#     log_info "Installing fonts..."

#     brew tap homebrew/cask-fonts || log_warning "Failed to tap homebrew/cask-fonts"

#     local fonts=(
#         font-fira-code
#         font-jetbrains-mono
#         font-source-code-pro
#     )

#     for font in "${fonts[@]}"; do
#         brew install --cask "$font" || log_warning "Failed to install $font"
#     done

#     log_success "Fonts installed"
# }

# Install fonts
install_fonts() {
    log_info "Installing fonts..."

    # REMOVED: brew tap homebrew/cask-fonts as it's deprecated/not strictly necessary.
    # The cask should install automatically from the main repository.

    local fonts=(
        font-fira-code
        font-jetbrains-mono
        font-source-code-pro
    )

    for font in "${fonts[@]}"; do
        # Use --cask flag for installation
        brew install --cask "$font" || log_warning "Failed to install $font"
    done

    log_success "Fonts installed"
}

# Install Java versions
install_java() {
    log_info "Installing Java versions..."

    # Replaced old/deprecated casks with modern Temurin (community-maintained OpenJDK) casks.
    local java_versions=(
        temurin8
        temurin11
        temurin17
        temurin21
    )

    for version in "${java_versions[@]}"; do
        brew install --cask "$version" || log_warning "Failed to install $version"
    done

    log_success "Java versions installed"
}

# Install Node.js via NVM
install_node() {
    log_info "Installing Node.js via NVM..."

    if [[ ! -d "$HOME/.nvm" ]]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash || log_warning "Failed to install NVM"

        # Source NVM
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true

        # Install latest LTS Node
        if command_exists nvm; then
            nvm install --lts || log_warning "Failed to install LTS Node"
            nvm use --lts || log_warning "Failed to use LTS Node"
            nvm alias default node || log_warning "Failed to set default node version"
        fi
    fi

    log_success "Node.js installed via NVM"
}

# Install global npm packages
install_npm_packages() {
    log_info "Installing global npm packages..."

    # Ensure NVM is sourced for npm to be available if NVM was just installed
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true

    if ! command_exists npm; then
        log_warning "npm not found. Skipping global npm package installation."
        return 1
    fi

    local npm_packages=(
        typescript ts-node
        aws-cdk
        tldr
        git-open
        pnpm
        yarn
    )

    for package in "${npm_packages[@]}"; do
        npm install -g "$package" || log_warning "Failed to install $package"
    done

    log_success "Global npm packages installed"
}

# Install Oh My Zsh and plugins
install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        # Use --unattended to avoid the initial shell switch prompt
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || log_warning "Failed to install Oh My Zsh"

        # Install plugins
        local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting" || log_warning "Failed to clone zsh-syntax-highlighting"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions" || log_warning "Failed to clone zsh-autosuggestions"
        git clone https://github.com/supercrabtree/k "$zsh_custom/plugins/k" || log_warning "Failed to clone k plugin"
    fi

    log_success "Oh My Zsh installed"
}

# Install tmux plugin manager
install_tmux_plugins() {
    log_info "Installing tmux plugins and themes..."

    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || log_warning "Failed to clone tpm"
    fi

    # Install Catppuccin Alacritty theme
    if [[ ! -d "$HOME/.config/alacritty/catppuccin" ]]; then
        mkdir -p "$HOME/.config/alacritty"
        git clone --depth 1 --branch yaml https://github.com/catppuccin/alacritty.git "$HOME/.config/alacritty/catppuccin" || log_warning "Failed to clone Catppuccin theme"
    fi

    log_success "tmux plugins and themes installed"
}

# Configure VS Code
configure_vscode() {
    log_info "Configuring Visual Studio Code extensions..."

    if ! command_exists code; then
        log_warning "VS Code 'code' command not found. Skipping extension installation."
        return 1
    fi

    local vscode_extensions=(
        dbaeumer.vscode-eslint
        ms-vscode.vscode-typescript-next # Replaced msjsdiag.debugger-for-chrome with a more general tool
        github.github-vscode-theme
        graphql.vscode-graphql
        ms-vsliveshare.vsliveshare
        davidanson.vscode-markdownlint
        pkief.material-icon-theme
        christian-kohler.path-intellisense
        esbenp.prettier-vscode
        prisma.prisma
        vscodevim.vim
        ms-python.python
        nrwl.angular-console # Added back from original list
        wmaurer.vscode-jumpy # Added back from original list
    )

    for extension in "${vscode_extensions[@]}"; do
        code --install-extension "$extension" || log_warning "Failed to install $extension"
    done

    log_success "VS Code configured"
}

# Install Python packages
install_python_packages() {
    log_info "Installing Python packages..."

    python3 -m pip install --user --upgrade pynvim Pygments || log_warning "Failed to install Python packages"

    log_success "Python packages installed"
}

# Setup dotfiles
setup_dotfiles() {
    log_info "Setting up dotfiles symbolic links..."

    local dotfiles=(
        ".aliases"
        ".bash_options"
        ".bash_profile"
        ".bash_prompt"
        ".bashrc"
        ".eslintrc"
        ".exports"
        ".functions"
        ".functions.zsh"
        ".gitconfig"
        ".gitignore_global"
        ".ideavimrc"
        ".inputrc"
        ".osx"
        ".tmux.conf"
        ".vimrc"
        ".zprofile"
        ".zshenv"
        ".zshrc"
    )

    for file in "${dotfiles[@]}"; do
        if [[ -f "$SCRIPT_DIR/$file" ]]; then
            if [[ -e "$HOME/$file" || -L "$HOME/$file" ]]; then
                log_info "Backing up existing $file"
                mv "$HOME/$file" "$HOME/${file}.backup.$(date +%Y%m%d_%H%M%S)"
            fi

            log_info "Creating symbolic link for $file"
            ln -sf "$SCRIPT_DIR/$file" "$HOME/$file"
        else
            log_warning "$file not found in dotfiles directory. Skipping link."
        fi
    done

    # Handle config directories (e.g., nvim)
    if [[ -d "$SCRIPT_DIR/nvim" ]]; then
        mkdir -p "$HOME/.config"
        if [[ -e "$HOME/.config/nvim" ]]; then
            log_info "Backing up existing nvim config directory"
            mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        log_info "Creating symbolic link for nvim config"
        ln -sf "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"
    fi

    log_success "Dotfiles setup complete"
}

# Download git-prompt if needed
setup_git_prompt() {
    if [[ ! -e "$HOME/.git-prompt.sh" ]]; then
        log_info "Downloading git-prompt..."
        curl -fsSL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o "$HOME/.git-prompt.sh" || log_warning "Failed to download git-prompt.sh"
        log_success "git-prompt downloaded"
    fi
}

# Main installation flow
main() {
    log_info "Starting macOS development environment setup..."

    # System preparation
    prepare_system

    # Core installations
    install_xcode_tools
    install_homebrew

    # Development environment
    install_dev_tools
    install_gui_apps
    install_fonts
    install_java

    # Node.js and global packages
    install_node
    install_npm_packages

    # Shell and terminal setup
    install_oh_my_zsh
    install_tmux_plugins

    # Application configuration
    configure_vscode
    install_python_packages

    # Dotfiles setup
    setup_dotfiles
    setup_git_prompt

    log_success "Installation complete! 🎉"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    log_info "Installation log saved to: $LOG_FILE"

    if ask_yes_no "Would you like to restart your shell now?" "n"; then
        exec "$SHELL"
    fi
}

# Run main function
main "$@"
