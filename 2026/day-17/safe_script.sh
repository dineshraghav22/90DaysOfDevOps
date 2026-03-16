#!/bin/bash
set -e

TESTDIR="/tmp/devops-test"

mkdir "$TESTDIR" || echo "Directory already exists"
cd "$TESTDIR"
touch testfile.txt
echo "Created testfile.txt in $TESTDIR"

echo "All steps completed successfully."
