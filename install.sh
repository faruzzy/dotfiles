#!/usr/bin/env bash

# macOS Development Environment Setup Script
# Automated setup for development tools, applications, and dotfiles

# Ensure script runs under bash (not sh) since we use bashisms
if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SCRIPT_DIR
readonly LOG_FILE="$HOME/install.log"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() { printf '%b\n' "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { printf '%b\n' "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
log_warning() { printf '%b\n' "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"; }
log_error() { printf '%b\n' "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }

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

        case "$(echo "$response" | tr '[:upper:]' '[:lower:]')" in
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
        sleep 10
        kill -0 "$$" || exit
    done 2>/dev/null &

    log_success "System prepared"
}

# Xcode Command Line Tools
install_xcode_tools() {
    log_info "Checking Xcode Command Line Tools..."

    if xcode-select -p &>/dev/null; then
        log_success "Command Line Tools already installed"
        return 0
    fi

    if ! command_exists xcode-select; then
        log_warning "xcode-select command not found. Cannot install Command Line Tools automatically."
        return 0
    fi

    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install

    # Wait for installation to complete
    # NOTE: The automated 'Agree' click from the original script is often unreliable/not recommended.
    # We will wait for the tool to be available, or the user to manually agree/install.
    log_warning "Please follow the on-screen prompts to install Command Line Tools."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done

    log_success "Xcode Command Line Tools installed"
}

# Homebrew installation and management
install_homebrew() {
    log_info "Checking Homebrew installation..."

    if command_exists brew; then
        log_success "Homebrew already installed"
        # Remove deprecated taps
        if brew tap | grep -q "^homebrew/cask-fonts$"; then
            log_info "Removing deprecated homebrew/cask-fonts tap..."
            brew untap homebrew/cask-fonts || log_warning "Failed to untap homebrew/cask-fonts"
        fi

        log_info "Updating Homebrew..."
        brew update
        brew upgrade
        brew upgrade --cask --greedy
        log_success "Homebrew updated"
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

# Install all Homebrew packages via Brewfile
install_brew_packages() {
    log_info "Installing Homebrew packages from Brewfile..."

    if [[ ! -f "$SCRIPT_DIR/Brewfile" ]]; then
        log_error "Brewfile not found at $SCRIPT_DIR/Brewfile"
        return 1
    fi

    # Ensure Rosetta 2 is installed (required for x86 JDKs like temurin@8 on Apple Silicon)
    if [[ "$(uname -m)" == "arm64" ]] && ! /usr/bin/pgrep -q oahd; then
        softwareupdate --install-rosetta --agree-to-license || log_warning "Failed to install Rosetta 2"
    fi

    sudo -v  # Refresh sudo for casks that need it

    brew bundle --file="$SCRIPT_DIR/Brewfile" || log_warning "Some Brewfile entries failed to install"

    # Post-install: link tools that need it
    brew link libtool 2>/dev/null || true
    brew link --overwrite graphviz 2>/dev/null || true

    # Install fzf shell integration
    local fzf_install="$(brew --prefix)/opt/fzf/install"
    if [[ -x "$fzf_install" ]]; then
        FZF_DEFAULT_OPTS_FILE="" "$fzf_install" --all --no-bash --no-fish || log_warning "Failed to install fzf shell integration"
    fi

    log_success "Homebrew packages installed"
}

# Install Node.js via NVM
install_node() {
    log_info "Installing Node.js via NVM..."

    if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash || log_warning "Failed to install NVM"
    fi

    # Source NVM and ensure an LTS Node version is installed/active.
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true

    if ! command_exists nvm; then
        log_warning "nvm is not available after installation attempt. Skipping Node.js setup."
        return 0
    fi

    nvm install --lts || log_warning "Failed to install LTS Node"
    nvm use --lts || log_warning "Failed to use LTS Node"
    nvm alias default node || log_warning "Failed to set default node version"

    log_success "Node.js installed via NVM"
}

# Install global npm packages
install_npm_packages() {
    log_info "Installing global npm packages..."

    # Ensure NVM is sourced for npm to be available if NVM was just installed
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true

    if ! command_exists npm; then
        log_warning "npm not found. Attempting to install Node.js before retrying..."
        install_node
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || true
    fi

    if ! command_exists npm; then
        log_warning "npm still not available after retry. Skipping global npm package installation."
        return 0
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
        if ! npm list -g "$package" &>/dev/null; then
            npm install -g "$package" || log_warning "Failed to install $package"
        fi
    done

    log_success "Global npm packages installed"
}

# Install Oh My Zsh and plugins
install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        # Use --unattended to avoid the initial shell switch prompt
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || log_warning "Failed to install Oh My Zsh"
    fi

    # Install plugins (always check, even if oh-my-zsh was already installed)
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    local plugins=(
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "marlonrichert/zsh-autocomplete"
        "supercrabtree/k"
    )

    for plugin in "${plugins[@]}"; do
        local plugin_name="${plugin##*/}"
        if [[ ! -d "$zsh_custom/plugins/$plugin_name" ]]; then
            git clone "https://github.com/$plugin.git" "$zsh_custom/plugins/$plugin_name" || log_warning "Failed to clone $plugin_name"
        fi
    done

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

    # Install tmuxwords.rb for fzf-based tmux word completion
    if [[ ! -x /usr/local/bin/tmuxwords.rb ]]; then
        sudo curl -o /usr/local/bin/tmuxwords.rb https://raw.githubusercontent.com/kiooss/dotmagic/master/bin/tmuxwords.rb \
            && sudo chmod +x /usr/local/bin/tmuxwords.rb \
           || log_warning "Failed to install tmuxwords.rb"
    fi

    log_success "tmux plugins and themes installed"
}

# Configure VS Code
configure_vscode() {
    log_info "Configuring Visual Studio Code extensions..."

    # Make the bundled VS Code CLI available in this shell session when present.
    if [[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]]; then
        export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
    fi

    if ! command_exists code; then
        log_warning "VS Code 'code' command not found. Attempting to install Visual Studio Code..."
        brew install --cask visual-studio-code || log_warning "Failed to install Visual Studio Code"

        if [[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]]; then
            export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
        fi
    fi

    if ! command_exists code; then
        log_warning "VS Code 'code' command still not found after retry. Skipping extension installation."
        return 0
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

    local installed_extensions
    installed_extensions="$(code --list-extensions 2>/dev/null || true)"

    for extension in "${vscode_extensions[@]}"; do
        if ! echo "$installed_extensions" | grep -qi "^${extension}$"; then
            code --install-extension "$extension" || log_warning "Failed to install $extension"
        fi
    done

    log_success "VS Code configured"
}

# Install Python packages
install_python_packages() {
    log_info "Installing Python packages..."

    # Use a dedicated venv for Neovim's Python dependencies
    local nvim_venv="$HOME/.config/nvim/venv"
    if [[ ! -d "$nvim_venv" ]]; then
        python3 -m venv "$nvim_venv" || log_warning "Failed to create Neovim Python venv"
    fi

    if [[ -d "$nvim_venv" ]]; then
        "$nvim_venv/bin/pip" install --upgrade pynvim Pygments || log_warning "Failed to install Python packages"
    fi

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
            if [[ "$(readlink "$HOME/$file" 2>/dev/null)" == "$SCRIPT_DIR/$file" ]]; then
                log_info "$file already linked correctly. Skipping."
                continue
            fi

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
        if [[ "$(readlink "$HOME/.config/nvim" 2>/dev/null)" == "$SCRIPT_DIR/nvim" ]]; then
            log_info "nvim config already linked correctly. Skipping."
        else
            mkdir -p "$HOME/.config"
            if [[ -e "$HOME/.config/nvim" ]]; then
                log_info "Backing up existing nvim config directory"
                mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            log_info "Creating symbolic link for nvim config"
            ln -sf "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"
        fi
    fi

    # Handle config files (e.g., starship.toml)
    if [[ -f "$SCRIPT_DIR/config/starship.toml" ]]; then
        if [[ "$(readlink "$HOME/.config/starship.toml" 2>/dev/null)" == "$SCRIPT_DIR/config/starship.toml" ]]; then
            log_info "starship.toml already linked correctly. Skipping."
        else
            mkdir -p "$HOME/.config"
            if [[ -e "$HOME/.config/starship.toml" ]]; then
                log_info "Backing up existing starship.toml"
                mv "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            log_info "Creating symbolic link for starship.toml"
            ln -sf "$SCRIPT_DIR/config/starship.toml" "$HOME/.config/starship.toml"
        fi
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

    # Development environment (formulas, casks, fonts, Java)
    install_brew_packages

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

    # Apply macOS system preferences
    if [[ -f "$SCRIPT_DIR/.osx" ]]; then
        log_info "Applying macOS system preferences..."
        bash "$SCRIPT_DIR/.osx" || log_warning "Failed to apply macOS preferences"
        log_success "macOS system preferences applied"
    fi

    log_success "Installation complete! 🎉"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    log_info "Installation log saved to: $LOG_FILE"

    if ask_yes_no "Would you like to restart your shell now?" "n"; then
        exec "$SHELL"
    fi
}

# Run main function
main "$@"
