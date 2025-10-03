# Faruzzy's Dotfiles

These are my personal dotfiles for macOS. They configure my development environment to my liking, with a focus on efficiency and a pleasant aesthetic.

![image](https://user-images.githubusercontent.com/766723/227434030-02bc9326-b9b3-4dc0-8201-f27a1e92856a.png)

## Philosophy

The guiding principle that I follow when configuring my dotfiles is that things should be easy to do. So easy in fact that it should favor laziness. Everything here revolves around `vim` and its movement.

## What's Inside?

This repository contains configurations for a variety of tools, including:

*   **Terminal:** Alacritty, tmux
*   **Shell:** Zsh (with Oh My Zsh)
*   **Editor:** Neovim
*   **Git:** git, git-delta, tig
*   **Other Tools:** fzf, bat, ripgrep, and many more.

## Installation

The `install.sh` script automates the setup process. It will:

1.  Install Xcode Command Line Tools.
2.  Install Homebrew and a wide range of packages.
3.  Install several GUI applications.
4.  Install programming languages like Python, Node.js, and Java.
5.  Set up Zsh with Oh My Zsh and plugins.
6.  Configure Neovim with a rich set of plugins.
7.  Create symbolic links for the dotfiles in this repository.

To start the installation, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/faruzzy/dotfiles/main/install.sh)"
```

## Neovim Configuration

My Neovim setup is tailored for a modern development workflow, with a focus on providing a rich and efficient coding experience. It includes a carefully selected set of plugins for everything from file exploration and code completion to Git integration and fuzzy finding.

## Other Configurations

This repository also includes configuration files for:

*   **Alacritty:** A fast, cross-platform, OpenGL terminal emulator.
*   **tmux:** A terminal multiplexer.
*   **Zsh:** A powerful shell with Oh My Zsh for plugin and theme management.
*   **bat:** A cat(1) clone with syntax highlighting and Git integration.
*   **and more...**

## Credits

Shamelessly copied from [various](https://github.com/junegunn/dotfiles) [places](https://github.com/addyosmani/dotfiles).