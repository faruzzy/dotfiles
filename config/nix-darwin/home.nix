# home.nix
{ config, pkgs, ... }:

{
  home.username = "paul";
  home.homeDirectory = "/Users/paul";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Additional packages for user
  home.packages = with pkgs; [
    # These are packages that might be better managed at user level
    tldr
    git-open
    pnpm
    typescript
    nodePackages.ts-node
    aws-cdk

    # Python packages
    python3Packages.pynvim
    python3Packages.pygments
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Paul"; # Replace with your name
    userEmail = "paul@example.com"; # Replace with your email

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    shellAliases = {
      ll = "ls -la";
      la = "ls -la";
      l = "ls -l";
      ".." = "cd ..";
      "..." = "cd ../..";
      lscleanup = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user";
    };

    initExtra = ''
      # Add any custom shell initialization here
      export PATH="$PATH:$HOME/.local/bin"

      # Initialize fzf if available
      if command -v fzf-share >/dev/null; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi
    '';
  };

  # Bash configuration (backup shell)
  programs.bash = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ll = "ls -la";
      la = "ls -la";
      l = "ls -l";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      resurrect
      continuum
      catppuccin
    ];

    extraConfig = ''
      # Additional tmux configuration
      set -g default-terminal "screen-256color"
      set -g mouse on

      # Catppuccin theme configuration
      set -g @catppuccin_flavour 'mocha'
    '';
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Add your preferred vim plugins here
      vim-sensible
      vim-airline
      vim-airline-themes
      fzf-vim
      vim-gitgutter
      vim-fugitive
    ];

    extraConfig = ''
      " Basic vim configuration
      set number
      set relativenumber
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent
      set wrap
      set smartcase
      set noswapfile
      set nobackup
      set undodir=~/.vim/undodir
      set undofile
      set incsearch
      set scrolloff=8
      set colorcolumn=80
      set signcolumn=yes

      " Color scheme
      colorscheme default
    '';
  };

  # Alacritty terminal configuration
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "buttonless";
      };

      font = {
        normal = {
          family = "Fira Code";
          style = "Regular";
        };
        size = 14;
      };

      colors = {
        primary = {
          background = "0x1e1e2e";
          foreground = "0xcdd6f4";
        };
      };
    };
  };

  # FZF configuration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    defaultCommand = "fd --type f";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
  };

  # Bat configuration (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "numbers,changes,header";
    };
  };

  # Direnv for environment management
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # VSCode extensions and settings
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode.vscode-typescript-next
      esbenp.prettier-vscode
      vscodevim.vim
      ms-python.python
      ms-vscode.vscode-json
      bradlc.vscode-tailwindcss
      graphql.vscode-graphql
      ms-vsliveshare.vsliveshare
      davidanson.vscode-markdownlint
      pkief.material-icon-theme
      christian-kohler.path-intellisense
      github.github-vscode-theme
    ];

    userSettings = {
      "editor.fontFamily" = "Fira Code";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 14;
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
      "editor.codeActionsOnSave" = {
        "source.fixAll.eslint" = true;
      };
      "workbench.colorTheme" = "GitHub Dark";
      "workbench.iconTheme" = "material-icon-theme";
      "terminal.integrated.fontFamily" = "Fira Code";
      "vim.useSystemClipboard" = true;
      "prettier.singleQuote" = true;
      "prettier.trailingComma" = "es5";
    };
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };

  # Symlink dotfiles
  home.file = {
    ".git-prompt.sh" = {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh";
        sha256 = "sha256-PLACEHOLDER"; # You'll need to get the actual hash
      };
    };
  };

  # Activation scripts for setup tasks
  home.activation = {
    setupTmuxPlugins = ''
      # Create tmux plugins directory and clone TPM
      mkdir -p ~/.tmux/plugins
      if [ ! -d ~/.tmux/plugins/tpm ]; then
        ${pkgs.git}/bin/git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
      fi
    '';

    setupAlacrittyTheme = ''
      # Setup catppuccin theme for alacritty
      mkdir -p ~/.config/alacritty
      if [ ! -d ~/.config/alacritty/catppuccin ]; then
        ${pkgs.git}/bin/git clone --depth 1 --branch yaml https://github.com/catppuccin/alacritty.git ~/.config/alacritty/catppuccin
      fi
    '';
  };

  # Node.js version management with nvm (handled via shell)
  home.sessionVariables = {
    NVM_DIR = "$HOME/.nvm";
  };

  # Additional shell initialization for nvm
  programs.zsh.initExtra = ''
    # NVM setup
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

    # Python environment
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"

    # Java environment
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
  '';
}
