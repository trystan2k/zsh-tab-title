#!/bin/bash

# Set terminal window and tab/icon title
#
# usage: title short_tab_title long_window_title
#
# See: http://www.faqs.org/docs/Linux-mini/Xterm-Title.html#ss3.1
# Fully supports screen, hyper, iterm, and probably most modern xterm and rxvt
# (In screen, only short_tab_title is used)
function title {
  emulate -L zsh
  setopt prompt_subst
  
  [[ "$EMACS" == *term* ]] && return

  tabTitle="\$1"
  termTitle="\$2"

  if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    print -Pn "\e]2;$termTitle:q\a" # set window name
    print -Pn "\e]1;$tabTitle:q\a" # set tab name
  elif [[ "$TERM_PROGRAM" == "Hyper" ]]; then
    print -Pn "\e]1;$termTitle:q\a" # set tab name
    print -Pn "\e]2;$tabTitle:q\a" # set window name
  else
    case "$TERM" in
      cygwin|xterm*|putty*|rxvt*|ansi|${~ZSH_TAB_TITLE_ADDITIONAL_TERMS})
        print -Pn "\e]2;$termTitle:q\a" # set window name
        print -Pn "\e]1;$tabTitle:q\a" # set tab name
      ;;

      screen*|tmux*)
        print -Pn "\ek$tabTitle:q\e\\" # set screen hardstatus
      ;;
    esac
  fi
}

ZSH_THEME_TERM_TAB_TITLE_IDLE="%20<..<%~%<<" #15 char left truncated PWD

if [[ "$ZSH_TAB_TITLE_DEFAULT_DISABLE_PREFIX" == true ]]; then
  ZSH_TAB_TITLE_PREFIX=""
elif [[ -z "$ZSH_TAB_TITLE_PREFIX" ]]; then
  ZSH_TAB_TITLE_PREFIX="%n@%m:"
fi

ZSH_THEME_TERM_TITLE_IDLE="$ZSH_TAB_TITLE_PREFIX %~ $ZSH_TAB_TITLE_SUFFIX"

# Runs before showing the prompt
function omz_termsupport_precmd {
  emulate -L zsh

  if [[ "$ZSH_TAB_TITLE_DISABLE_AUTO_TITLE" == true ]]; then
    return
  fi

  if [[ "$ZSH_TAB_TITLE_ONLY_FOLDER" == true ]]; then
    ZSH_THEME_TERM_TAB_TITLE_IDLE=${PWD##*/}
  fi

  title "$ZSH_THEME_TERM_TAB_TITLE_IDLE" "$ZSH_THEME_TERM_TITLE_IDLE"
}

# Runs before executing the command
function omz_termsupport_preexec {
  emulate -L zsh
  setopt extended_glob

  if [[ "$ZSH_TAB_TITLE_DISABLE_AUTO_TITLE" == true ]]; then
    return
  fi

  if [[ "$ZSH_TAB_TITLE_ENABLE_FULL_COMMAND" == true ]]; then
  	  # full command
	  local CMD=${1:gs/%/%%}
  else
	  # cmd name only, or if this is sudo or ssh, the next cmd
	  local CMD=${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}
  fi
  local LINE="${2:gs/%/%%}"

  if [[ "$ZSH_TAB_TITLE_CONCAT_FOLDER_PROCESS" == true ]]; then
    title "${PWD##*/}:%100>...>$LINE%<<" "${PWD##*/}:${CMD}"
  else
    title "%100>...>$LINE%<<" "$CMD"
  fi  
}

# Execute the first time, so it show correctly on terminal load
title "$ZSH_THEME_TERM_TAB_TITLE_IDLE" "$ZSH_THEME_TERM_TITLE_IDLE"

autoload -U add-zsh-hook
add-zsh-hook precmd omz_termsupport_precmd
add-zsh-hook preexec omz_termsupport_preexec
