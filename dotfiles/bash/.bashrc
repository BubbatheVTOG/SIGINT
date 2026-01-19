# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# opencode
export PATH=/home/bubba/.opencode/bin:$PATH

# Highlight directories in Cyan and Executables in Mint Green
export LS_COLORS="di=01;38;5;81:ex=01;38;5;48:"
alias ls='eza'


# Define the colors
CYAN='\[\e[38;5;81m\]'    # Approximates #33CCFF
MINT='\[\e[38;5;48m\]'    # Approximates #00FF99
WHITE='\[\e[37m\]'
RESET='\[\e[0m\]'

# A minimalist prompt: [directory] >
export PS1="${CYAN}\w ${MINT}❯ ${RESET}"


alias llama_start='./home/bubba/git/llama-cpp/build/bin/llama-server --model ~/models/deepseek-r1-8b-q4_k_m.gguf --host 127.0.0.1 --port 8080 --gpu-layers 35'

fastfetch
eval "$(zoxide init bash)"
