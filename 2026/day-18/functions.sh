#!/bin/bash

greet() {
    echo "Hello, $1!"
}

add() {
    local RESULT=$(( $1 + $2 ))
    echo "Sum of $1 + $2 = $RESULT"
}

greet "Dinesh"
greet "DevOps World"
add 10 25
add 100 200
