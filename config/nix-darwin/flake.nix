# flake.nix
{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile
      environment.systemPackages = with pkgs; [
        # Development tools
        vim
        neovim
        git
        tree
        wget
        jq
        curl
        bat
        ripgrep
        fd
        fzf
        eza

        # Languages and runtimes
        python3
        python39
        nodejs
        yarn
        deno

        # Build tools
        ninja
        cmake
        gettext

        # Database
        postgresql

        # Media
        imagemagick
        ffmpeg

        # Terminal tools
        tmux
        reattach-to-user-namespace
        gnu-sed
        gnupg

        # AWS and cloud tools
        awscli

        # Other utilities
        mkcert
        nss
        xquartz
        translate-shell
        youtube-dl
        cocoapods
        allure
        graphviz
        libtool
        mas

        # Shell enhancements
        bash-completion
        zsh-completions

        # Search tools
        the_silver_searcher
        ngrep

        # Compression
        xz

        # Java tooling
        jenv
        maven

        # Lua
        lua
        luajit

        # HTTP tools
        http-server

        # Version control
        tig
        gh
        git-delta

        # Music
        cmus

        # File tools
        libpq

        # Security
        krb5

        # System libraries
        libevent
        mpdecimal
        readline
        unibilium
        ca-certificates
        msgpack
        utf8proc
        libtermkey
        ncurses
        libuv
        ruby
        libvterm
        openssl
        sqlite
        gdbm
        libyaml
        libffi
        pcre
        pcre2
        z
        berkeley-db
        luv
        tree-sitter

        # Python version management
        pyenv
      ];

      # Homebrew cask applications
      homebrew = {
        enable = true;
        casks = [
          "rectangle"
          "alt-tab"
          "app-cleaner"
          "bettertouchtool"
          "path-finder"
          "firefox"
          "firefox@developer-edition"
          "google-chrome-canary"
          "google-chrome"
          "caffeine"
          "keka"
          "whatsapp"
          "skitch"
          "kap"
          "qbserve"
          "1password"
          "google-drive"
          "visual-studio-code"
          "pdfsam-basic"
          "intellij-idea"
          "colorsnapper"
          "spectacle"
          "alacritty"
          "karabiner-elements"
          "maccy"
          "macfuse"
          "nightowl"
          "keepingyouawake"
          "visualvm"
          "vlc"
          "spotify"
          "java6"
          "java7"
          "adoptopenjdk8"
          "adoptopenjdk11"
        ];

        taps = [
          "homebrew/cask-fonts"
          "koekeishiya/formulae"
        ];

        brews = [
          "viz"
          "yabai"
          "skhd"
          "font-fira-code"
        ];
      };

      # Fonts
      fonts.fontDir.enable = true;
      fonts.fonts = with pkgs; [
        fira-code
        fira-code-symbols
      ];

      # Auto upgrade nix package and the daemon service
      services.nix-daemon.enable = true;
      nix.package = pkgs.nix;

      # Necessary for using flakes on this system
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment
      programs.zsh.enable = true;
      programs.bash.enable = true;

      # Set Git commit hash for darwin-version
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing
      system.stateVersion = 4;

      # The platform the configuration will be used on
      nixpkgs.hostPlatform = "aarch64-darwin"; # or "x86_64-darwin" for Intel Macs

      # System preferences (equivalent to your .osx script)
      system.defaults = {
        # Dock settings
        dock = {
          autohide = true;
          tilesize = 55;
        };

        # Finder settings
        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          ShowStatusBar = true;
          ShowPathbar = true;
          FXEnableExtensionChangeWarning = false;
          FXDefaultSearchScope = "SCcf";
          QuitMenuItem = true;
          _FXPreferredViewStyle = "clmv";
          _FXShowPosixPathInTitle = true;
        };

        # Global settings
        NSGlobalDomain = {
          # Disable automatic capitalization, smart dashes, periods, quotes, and spelling correction
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;

          # Save to disk by default
          NSDocumentSaveNewDocumentsToCloud = false;

          # Disable natural scrolling
          "com.apple.swipescrolldirection" = false;

          # Key repeat settings
          ApplePressAndHoldEnabled = false;
          KeyRepeat = 1;
          InitialKeyRepeat = 10;

          # Locale settings
          AppleLanguages = [ "en" "nl" ];
          AppleLocale = "en_US@currency=USD";
          AppleMeasurementUnits = "Inches";
          AppleMetricUnits = true;

          # Show all file extensions
          AppleShowAllExtensions = true;

          # Enable text selection in Quick Look
          QLEnableTextSelection = true;
        };

        # Trackpad settings
        trackpad = {
          Clicking = true;
          TrackpadRightClick = true;
          TrackpadCornerSecondaryClick = 2;
        };

        # Screenshots
        screencapture = {
          location = "~/Desktop";
          type = "png";
        };

        # LaunchServices
        LaunchServices = {
          LSQuarantine = false;
        };

        # Printing
        universalaccess = {
          reduceTransparency = false;
        };
      };

      # Keyboard settings
      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };

      # Additional system settings
      system.activationScripts.postUserActivation.text = ''
        # Show the ~/Library folder
        chflags nohidden ~/Library

        # Show the /Volumes folder
        sudo chflags nohidden /Volumes
      '';

      # Users configuration
      users.users.paul = {
        name = "paul";
        home = "/Users/paul";
      };

      # Home Manager
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.paul = import ./home.nix;
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
      ];
    };

    # Expose the package set, including overlays, for convenience
    darwinPackages = self.darwinConfigurations."simple".pkgs;
  };
}
