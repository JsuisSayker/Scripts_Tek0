#!/bin/bash

detect_shell_config() {
    if [[ "$SHELL" == */bash ]]; then
        config_file="$HOME/.bashrc"
    elif [[ "$SHELL" == */zsh ]]; then
        config_file="$HOME/.zshrc"
    else
        config_file="$HOME/.bashrc"
    fi
}

remove_from_startup() {
    startup_line="if [ -t 1 ]; then ~/.local/bin/install.sh; fi"

    escaped_startup_line=$(echo "$startup_line" | sed -e 's/[]\/$*.^[]/\\&/g')

    sed -i "/$escaped_startup_line/d" "$config_file"
}

remove_script_file() {
    script_file="$HOME/.local/bin/install.sh"

    if [[ -f "$script_file" ]]; then
        rm "$script_file"
    fi
}

detect_shell_config
remove_from_startup
remove_script_file
