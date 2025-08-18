# Modern bash configuration for terminal container

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History configuration
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Tmux aliases
alias ta='tmux attach'
alias tls='tmux ls'
alias tn='tmux new-session'

# Set a colorful prompt
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# Welcome message
if [[ -z "$TMUX" ]]; then
    echo "🖥️  Welcome to TTYdx Terminal Container"
    echo "────────────────────────────────────────"
    echo "📁 Home: $HOME"
    echo "🐚 Shell: $SHELL"
    echo "📅 $(date)"
    echo ""
    echo "💡 Tips:"
    echo "  • Use 'tmux' for multiple sessions"
    echo "  • Press Ctrl+A for tmux commands"
    echo "  • Type 'sysinfo' for system information"
    echo ""
fi

# Auto-start tmux if not already in tmux and in interactive shell
if [[ -z "$TMUX" ]] && [[ $- == *i* ]]; then
    exec tmux new-session -A -s main
fi