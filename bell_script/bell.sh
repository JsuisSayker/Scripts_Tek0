#!/bin/bash

#!/bin/bash

n=1

while true; do
    for ((i=0; i<n; i++)); do
        printf '\a'
    done

    sleep 2

    current=$(pactl get-sink-volume "$(pactl get-default-sink)" | grep -o '[0-9]\+%' | head -1 | tr -d '%')

    if [ "$current" -lt 120 ]; then
        pactl set-sink-volume "$(pactl get-default-sink)" +10%
    fi

    ((n++))
done
