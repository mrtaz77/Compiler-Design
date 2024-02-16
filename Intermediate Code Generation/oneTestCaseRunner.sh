#!/bin/bash
clear
# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <c_filename>"
    exit 1
fi

# Input file name provided as an argument
c_file="$1"

# Check if the input file exists
if [ ! -f "Sample Input/$c_file" ]; then
    echo "File $c_file not found in Sample Input directory."
    exit 1
fi

# Extract the filename without extension
filename_without_extension=$(basename "$c_file" ".c")

# Create a folder for the specific .c file in Sample_Output directory if not already exists
output_folder="Sample Output/$filename_without_extension"
mkdir -p "$output_folder"

# Copy the .c file to the respective folder
cp "Sample Input/$c_file" "$output_folder/"

# Run a.out for the .c file
./a.out "Sample Input/$c_file" >  "$output_folder/output.txt"

# Move generated output files to the specific directory
mv code.asm recsrc.txt token.txt log.txt optcode.asm error.txt parsetree.txt code.txt "$output_folder/"

echo "Task completed successfully."