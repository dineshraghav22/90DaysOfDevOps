#!/bin/bash

GLOBAL_VAR="I am global"

with_local() {
    local MY_VAR="I am local to with_local()"
    echo "Inside with_local: MY_VAR = $MY_VAR"
}

without_local() {
    MY_VAR="I leaked from without_local()"
    echo "Inside without_local: MY_VAR = $MY_VAR"
}

with_local
echo "After with_local: MY_VAR = '${MY_VAR:-not set}'"

without_local
echo "After without_local: MY_VAR = '$MY_VAR'"

echo "GLOBAL_VAR = $GLOBAL_VAR"
