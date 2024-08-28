PROMPT="%(?:%{$fg_bold[green]%}👉 :%{$fg_bold[red]%}💥 )"
PROMPT+=' %{$fg[red]%}%c%{$reset_color%} $(git_prompt_info)'
RPROMPT="%B%K{pink}%F{cyan}%t %f%k%b"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[default]%}git:(%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[default]%}) %{$fg[yellow]%}✏️ "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}) ✅"
