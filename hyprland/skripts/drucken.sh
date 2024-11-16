#!/bin/bash

# Check if the input PDF file is provided

input_pdf="$1"

# Check if the input file exists
if [ ! -f "$input_pdf" ]; then
    echo "Input PDF file '$input_pdf' not found."
    exit 1
fi

remote_name=$(rofi -dmenu -p "Please enter a number:")

# Check if a remote name was provided
if [ -z "$remote_name" ]; then
    echo "No remote name provided."
    exit 1
fi

REMOTE="drucken:/drucken/$remote_name"
rclone delete "drucken:/drucken"

source /opt/miniconda3/etc/profile.d/conda.sh
conda activate pdftrafo 

case $2 in
  "-d")
    python ~/projects/pdf_transform/pdf_transform/dense.py "$input_pdf"
    ;;
  *)
    python ~/projects/pdf_transform/pdf_transform/pixelated.py "$input_pdf"
    ;;
esac


filename="${input_pdf%.*}"
extension="${input_pdf##*.}"
input_pdf="${filename}_RESHAPE.${extension}"

pdftk "$input_pdf" cat end-1 output reversed.pdf
NUMPAGES=$(pdftk reversed.pdf dump_data | grep NumberOfPages | awk '{print $2}')
PAGES_PER_SPLIT=50

# Create a directory to store split PDFs
mkdir -p split_pdfs

# Split the reversed PDF into separate files of max 50 pages each
for ((START_PAGE=1; START_PAGE<=NUMPAGES; START_PAGE+=PAGES_PER_SPLIT)); do
    END_PAGE=$((START_PAGE+PAGES_PER_SPLIT-1))
    if [ $END_PAGE -gt $NUMPAGES ]; then
        END_PAGE=$NUMPAGES
    fi

    # Calculate the corresponding original page numbers
    OriginalStartPage=$((NUMPAGES - START_PAGE + 1))
    OriginalEndPage=$((NUMPAGES - END_PAGE + 1))

    # Ensure page numbers are in ascending order for labeling
    if [ $OriginalStartPage -lt $OriginalEndPage ]; then
        TEMP=$OriginalStartPage
        OriginalStartPage=$OriginalEndPage
        OriginalEndPage=$TEMP
    fi

    OUTPUT_FILE="split_pdfs/pages_${OriginalEndPage}-${OriginalStartPage}.pdf"
    pdftk reversed.pdf cat $START_PAGE-$END_PAGE output "$OUTPUT_FILE"
done
# Upload the split PDFs to the drive using rclone
rclone copy split_pdfs "$REMOTE"

# Clean up temporary files
rm reversed.pdf
rm -r split_pdfs

# Get the file count in the remote directory
file_count=$(rclone ls "$REMOTE" | wc -l)

# Display a notification (assuming hyprctl is used for notifications)
hyprctl notify 0 5000 'rgb(43c175)' "Directory '$REMOTE' exists with $file_count files."
