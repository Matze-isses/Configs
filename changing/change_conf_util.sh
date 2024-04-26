#!/bin/bash

# Configuration file path

# Check if sufficient arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 [path] [seperator] [keyword] [value]"
    exit 1
fi

# Assign arguments to variables
CONFIG_FILE="$1"
SEPARATOR="$2"
KEYWORD="$3"
VALUE="$4"

# Check if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file $CONFIG_FILE not found."
    exit 1
fi

GREP_PATTERN="^$KEYWORD$SEPARATOR"
SED_PATTERN="/^$KEYWORD$SEPARATOR/c\\$KEYWORD$SEPARATOR$VALUE"

# Check if keyword exists in the file
if grep -q "$GREP_PATTERN" "$CONFIG_FILE"; then
    # Keyword exists, replace the line
    sed -i "$SED_PATTERN" "$CONFIG_FILE"
    echo "Updated $KEYWORD in $CONFIG_FILE."
else
    # Keyword does not exist, add at the end
    echo "$KEYWORD$SEPARATOR$VALUE" >> "$CONFIG_FILE"
    echo "Added $KEYWORD to $CONFIG_FILE."
fi
