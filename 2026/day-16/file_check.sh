#!/bin/bash

read -p "Enter a filename: " FILENAME

if [ -f "$FILENAME" ]; then
    echo "File '$FILENAME' exists."
else
    echo "File '$FILENAME' does NOT exist."
fi
