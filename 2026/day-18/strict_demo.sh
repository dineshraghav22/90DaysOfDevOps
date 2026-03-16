#!/bin/bash
set -euo pipefail

# Demonstrating set -e: script exits on any error
echo "set -e: Script exits on any failed command"
echo "This line runs fine"

# Demonstrating set -u: undefined variable causes exit
# Uncomment to test: echo "Undefined: $UNDEFINED_VAR"

# Demonstrating set -o pipefail: pipe failure is caught
# Without pipefail, this would succeed even though grep fails:
# cat /etc/hostname | grep "NOTFOUND" | wc -l

echo "Strict mode is active. All good."
