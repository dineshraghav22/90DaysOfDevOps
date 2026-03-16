#!/bin/bash

SERVICE="sshd"

read -p "Do you want to check the status of '$SERVICE'? (y/n): " ANSWER

if [ "$ANSWER" = "y" ] || [ "$ANSWER" = "Y" ]; then
    STATUS=$(systemctl is-active "$SERVICE" 2>/dev/null)
    if [ "$STATUS" = "active" ]; then
        echo "$SERVICE is active and running."
    else
        echo "$SERVICE is NOT running (status: $STATUS)."
    fi
else
    echo "Skipped."
fi
