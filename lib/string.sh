#!/bin/bash

function trim_whitespace {
    echo "$1" | sed -e 's/^ *//' -e 's/ *$//'
}

function trim_leading_whitespace {
    echo "$1" | sed -e 's/^ *//'
}

function trim_trailing_whitespace {
    echo "$1" | sed -e 's/ *$//'
}