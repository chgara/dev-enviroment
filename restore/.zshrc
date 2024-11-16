export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
# (cat ~/.cache/wal/sequences &)
export ZSH="$HOME/.oh-my-zsh"

bgnotify_bell=false   ## disable terminal bell
bgnotify_threshold=7  ## set your own notification threshold

function bgnotify_formatted {
  ## $1=exit_status, $2=command, $3=elapsed_time

  # Humanly readable elapsed time
  local elapsed="$(( $3 % 60 ))s"
  (( $3 < 60 ))   || elapsed="$((( $3 % 3600) / 60 ))m $elapsed"
  (( $3 < 3600 )) || elapsed="$((  $3 / 3600 ))h $elapsed"

  [ $1 -eq 0 ] && title="Holy Smokes Batman" || title="Holy Graf Zeppelin"
  [ $1 -eq 0 ] && icon="$HOME/icons/success.png" || icon="$HOME/icons/fail.png"
  bgnotify "$title - took ${elapsed}" "$2" "$icon"
}

# ZSH
export ZSH_FZF_HISTORY_SEARCH_BIND='^f'
export ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS="--height=99%"

plugins=(
	git 
	autojump
	bgnotify
	zsh-vi-mode
	zsh-autosuggestions
	zsh-fzf-history-search
)
ZSH_THEME="cloud"
source $ZSH/oh-my-zsh.sh

# Configs
export VISUAL=nvim;
export EDITOR=nvim;

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias logout="loginctl terminate-user phobos"

echo ""
echo ""
neofetch --ascii ~/.config/neofetch/ascii_files/ibm.txt --ascii_colors 11 11 11

# FZF history search
fzf-history-widget() {
  local selected_command
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null
  selected_command=$(fc -rl 1 | fzf +s --tac --tiebreak=index --no-sort +m --query="$LBUFFER" --preview='echo {}' --preview-window=down:3:hidden:wrap --bind=ctrl-r:toggle-preview)
  if [ -n "$selected_command" ]; then
    local num=$(echo "$selected_command" | cut -d ' ' -f 1)
    BUFFER=$(fc -ln "$num" "$num")
    CURSOR=$#BUFFER
  fi
  zle reset-prompt
  zle -R
}

zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

# pnpm
export PNPM_HOME="/home/phobos/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# pnpm
[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
export CLR_ICU_VERSION_OVERRIDE=$(pacman -Q icu | awk '{split($0,a," ");print a[2]}' | awk '{split($0,a,"-");print a[1]}')
export PATH="$PATH:~/.dotnet/tools"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
