
#!/bin/bash

# Directory where images will be copied
DEST_DIR="/home/admin/Pictures/CameraFotos/Unsorted/Usable/"

# Check if destination directory exists, if not create it
if [ ! -d "$DEST_DIR" ]; then
  mkdir -p "$DEST_DIR"
fi

# Function to copy and enumerate files
copy_and_enumerate() {
  local filepath="$1"
  local filename=$(basename -- "$filepath")
  local extension="${filename##*.}"
  local name="${filename%.*}"
  
  if [[ "$extension" != "JPG" ]]; then
    echo "Error: Only .jpg files are allowed."
    exit 1
  fi

  local new_filename="$filename"
  local counter=1

  # Check for existing files and enumerate if needed
  while [[ -e "$DEST_DIR/$new_filename" ]]; do
    new_filename="${name}_$counter.$extension"
    ((counter++))
  done

  # Copy the file to the destination directory
  cp "$filepath" "$DEST_DIR/$new_filename"
  echo "File copied to $DEST_DIR/$new_filename"
}

# Check if filepath is provided as an argument
if [[ -z "$1" ]]; then
  echo "Usage: $0 <filepath>"
  exit 1
fi

# Call the function with the provided filepath
copy_and_enumerate "$1"
