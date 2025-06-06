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

For installing a predefined profile:

```bash
~/.dotfiles$ ./install-profile <profile> [<configs...>]
```

For installing single configurations:

```bash
~/.dotfiles$ ./install-standalone <configs...>
```

If a configuration requires elevated privileges, add -sudo to its name:
```bash
~/.dotfiles$ ./install-standalone vim-sudo 
```
