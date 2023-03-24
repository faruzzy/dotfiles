# Faruzzy dotfiles configuration

My configuration files for Linux / Mac OS X
![image](https://user-images.githubusercontent.com/766723/227434030-02bc9326-b9b3-4dc0-8201-f27a1e92856a.png)

> Shamelessly copied from [various](https://github.com/junegunn/dotfiles) [places](https://github.com/addyosmani/dotfiles)

## Philosophy

The guiding principle that I follow when configuring my dotfiles is that things
should be easy to do. So easy in fact that it should favor laziness.

Everything here revolves around `vim` and its movement.

# Vim

## Customizations

* Line numbers
* Ruler
* Make searching highlighted, incremental, and case insensitive unless a capital letter is used
* Always show a Status line
* Allow backspacing over everything (indentations, eol, and start characters) in insert mode
* Automatically resize splits when resizing the Vim window (GUI only)
* Write a privileged file with `<leader>W` it will prompt for sudo password when writting

## Syntax

* [php.vim](https://github.com/StanAngeloff/php.vim)
* [kotlin.vim](https://github.com/udalov/kotlin-vim)
* [vim-go](https://github.com/fatih/vim-go)

## Plugins

## [Ack.vim](http://github.com/mileszs/ack.vim)

Ack.vim uses ack to search inside the current directory for a pattern.
You can learn more about it with :help Ack.


