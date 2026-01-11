#!/usr/bin/env zsh
#bashbash Set terminal window and tab/icon title
#
# usage: title short_tab_title long_window_title
#
# See: http://www.faqs.org/docs/Linux-mini/Xterm-Title.html#ss3.1
# Fully supports screen, hyper, iterm, zellij, and probably most modern xterm and rxvt
# (In screen, only short_tab_title is used)

# Detect Zellij
_in_zellij() { [[ -n "$ZELLIJ" || -n "$ZELLIJ_SESSION_NAME" ]]; }

# Zellij rename actions
_zt_rename_tab()  { command zellij action rename-tab  "$1" >/dev/null 2>&1; }
_zt_rename_pane() { command zellij action rename-pane "$1" >/dev/null 2>&1; }

# Optional associative arrays for custom name mapping
(( ${+ZSH_TAB_TITLE_CMD_MAP} )) || typeset -gA ZSH_TAB_TITLE_CMD_MAP

function title {
  emulate -L zsh
  setopt prompt_subst

  [[ "$EMACS" == *term* ]] && return

  # Handle Zellij first - use actual arguments directly
  if _in_zellij; then
    # Expand prompt sequences in arguments before passing to zellij
    local tab_name="$(print -P "$1")"
    local pane_name="$(print -P "$2")"
    _zt_rename_tab "$tab_name"
    _zt_rename_pane "$pane_name"
    return
  fi

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
      xterm-kitty)
        print -Pn "\e]1;$termTitle:q\a" # set window name
        print -Pn "\e]2;$tabTitle:q\a" # set tab name
      ;;

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

function setTerminalTitleInIdle {

  if [[ "${ZSH_TAB_TITLE_DISABLE_AUTO_TITLE:-}" == true ]]; then
    return
  fi

  if [[ "${ZSH_TAB_TITLE_ONLY_FOLDER:-}" == true ]]; then
    ZSH_THEME_TERM_TAB_TITLE_IDLE=${PWD##*/}
  else
    ZSH_THEME_TERM_TAB_TITLE_IDLE="%20<..<%~%<<" #15 char left truncated PWD
  fi

  if [[ "${ZSH_TAB_TITLE_DEFAULT_DISABLE_PREFIX:-}" == true ]]; then
  ZSH_TAB_TITLE_PREFIX=""
  elif [[ -z "${ZSH_TAB_TITLE_PREFIX:-}" ]]; then
    ZSH_TAB_TITLE_PREFIX="%n@%m:"
  fi

  ZSH_THEME_TERM_TITLE_IDLE="${ZSH_TAB_TITLE_PREFIX:-} %~ $ZSH_TAB_TITLE_SUFFIX"

  title "$ZSH_THEME_TERM_TAB_TITLE_IDLE" "$ZSH_THEME_TERM_TITLE_IDLE"
}

# Runs before showing the prompt
function omz_termsupport_precmd {
  emulate -L zsh

  setTerminalTitleInIdle
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
    local LINE=${2:gs/%/%%}
  else
	  # cmd name only, or if this is sudo or ssh, the next cmd
	  local CMD=${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}
    local LINE=${2[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}
  fi

  if (( ${+ZSH_TAB_TITLE_CMD_MAP} )) && (( ${#ZSH_TAB_TITLE_CMD_MAP} > 0 )); then
    local base_cmd="${CMD}"

    if [[ -n "${ZSH_TAB_TITLE_CMD_MAP[$base_cmd]:-}" ]]; then
      local mapped_cmd="${ZSH_TAB_TITLE_CMD_MAP[$base_cmd]}"

      CMD="$mapped_cmd"

      if [[ "$ZSH_TAB_TITLE_ENABLE_FULL_COMMAND" == true ]]; then
        LINE="${LINE/$base_cmd/$mapped_cmd}"
      else
        LINE="$mapped_cmd"
      fi
    fi
  fi

  if [[ "$ZSH_TAB_TITLE_CONCAT_FOLDER_PROCESS" == true ]]; then
    title "${PWD##*/}:%100>...>$LINE%<<" "${PWD##*/}:${CMD}"
  else
    title "%100>...>$LINE%<<" "$CMD"
  fi  
}

# Execute the first time, so it show correctly on terminal load
setTerminalTitleInIdle

autoload -U add-zsh-hook
add-zsh-hook precmd omz_termsupport_precmd
add-zsh-hook preexec omz_termsupport_preexec
