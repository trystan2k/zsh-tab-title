# ZSH Tab Title

[![v1.2.0](https://img.shields.io/badge/version-1.1.0-brightgreen.svg)](https://github.com/trystan2k/zsh-tab-title/tree/v1.2.0)

A zsh plugin that allows you to set a terminal header like any of PROMPT

A ZSH plugin that automatically sets terminal tab titles based on current location and task.

This is completely based on [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/termsupport.zsh) term support library.

## Installation

### Using [zplugin](https://github.com/zdharma/zplugin)

Add `zplugin light trystan2k/zsh-tab-title` into `.zshrc`

### Using [zpm](https://github.com/zpm-zsh/zpm)

Add `zpm load trystan2k/zsh-tab-title` into `.zshrc`

### Using [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)

Execute `git clone https://github.com/trystan2k/zsh-tab-title ~/.oh-my-zsh/custom/plugins/zsh-tab-title`. Add `zsh-tab-title` into plugins array in `.zshrc`

### Using [antigen](https://github.com/zsh-users/antigen)

Add `antigen bundle trystan2k/zsh-tab-title` into `.zshrc`

### Using [zgen](https://github.com/tarjoilija/zgen)

Add `zgen load trystan2k/zsh-tab-title` into `.zshrc`

## Configuration

You can configure the prefix and/or suffix to be showed in tab title, besides the current folder.

### PREFIX

The prefix can be configured using the variable `ZSH_TAB_TITLE_PREFIX` and it will be added **before** the current folder, in tab title. For example:

```sh
ZSH_TAB_TITLE_PREFIX='$USER@$HOST - '
```

By default, if no value is informed, it is used the value `%m@%n:` which will show the user name and computer name, separated by @. For example: `trystan2k@MyPC: /home/trystan2k`. This default value can be disabled if variable `ZSH_TAB_TITLE_DEFAULT_DISABLE_PREFIX` is set to try. For example:

```sh
ZSH_TAB_TITLE_DEFAULT_DISABLE_PREFIX=true
```

### SUFFIX

The suffix can be configured using the variable `ZSH_TAB_TITLE_SUFFIX` and it will be added **after** the current folder, in tab title. For example:

```sh
ZSH_TAB_TITLE_SUFFIX='- $USER'
```

This variable has no default value, so if nothing is informed, no suffix is added