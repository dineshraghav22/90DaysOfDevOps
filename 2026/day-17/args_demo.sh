#!/bin/bash

echo "Script name: $0"
echo "Total arguments: $#"
echo "All arguments: $@"

echo ""
echo "--- Each argument ---"
for arg in "$@"; do
    echo "  $arg"
done
