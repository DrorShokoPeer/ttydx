# Modern zsh configuration for terminal container

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"

# Plugins
plugins=(
    git
    docker
    docker-compose
    kubectl
    npm
    node
    python
    pip
    tmux
    ssh-agent
    history-substring-search
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='vim'

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

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

# Navigation
alias home='cd ~'
alias root='cd /'

# System info
alias sysinfo='echo "OS: $(uname -s) $(uname -r)" && echo "User: $(whoami)" && echo "Shell: $SHELL"'

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