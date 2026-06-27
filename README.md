# Dotfiles

Dotfile management using [Dotbot](https://github.com/anishathalye/dotbot).

## Installation

```bash
~$ git clone --recursive https://github.com/Albroy/dotfiles.git .dotfiles
```
or if using **ssh**
```bash
~$ git clone --recursive git@github.com:Albroy/dotfiles.git .dotfiles
```

For installing single configurations:

```bash
~/.dotfiles$ ./setup <configs...>
```

If a configuration requires elevated privileges, add -sudo to its name:
```bash
~/.dotfiles$ ./setup vim-sudo 
```
