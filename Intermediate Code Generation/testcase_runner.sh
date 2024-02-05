#!/bin/bash

# Create "Sample Output" directory if it doesn't exist
mkdir -p "Sample Output"

# Iterate over all .c files in the "Sample Input" directory
for input_file in "Sample Input"/*.c; do
    # Get the filename without extension
    filename=$(basename "$input_file" .c)

    # Create a folder for each .c file in "Sample Output" directory
    mkdir -p "Sample Output/$filename"

    # Copy the .c file to its respective folder
    cp "$input_file" "Sample Output/$filename/"

    # Run a.out for each .c file and store all output files in the respective folder
    ./a.out "$input_file" > "Sample Output/$filename/output.txt"

    # Move all generated output files (both .txt and .asm) to the respective folder
    mv *.txt *.asm "Sample Output/$filename/"

	echo "parsed "$filename" successfully"
done
