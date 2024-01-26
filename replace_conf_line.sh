#!/bin/bash

# Check if sufficient arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 [path] [line number] [new line]"
    exit 1
fi

# Assign arguments to variables
FILE_PATH="$1"
LINE_NUM="$2"
NEW_LINE="$3"

# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File $FILE_PATH not found."
    exit 1
fi

# Check if the line number is a number
if ! [[ $LINE_NUM =~ ^[0-9]+$ ]]; then
    echo "Error: Line number must be a valid number."
    exit 1
fi

# Replace the line
awk -v ln="$LINE_NUM" -v new_line="$NEW_LINE" 'NR == ln {print new_line; next} {print}' "$FILE_PATH" > tmpfile && mv tmpfile "$FILE_PATH"

echo "Line $LINE_NUM in $FILE_PATH replaced with the new content."
