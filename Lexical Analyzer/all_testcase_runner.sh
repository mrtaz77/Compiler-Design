#!/bin/bash

flex -o scanner.cpp scanner.l
g++ scanner.cpp -lfl -o scanner.out

# Define the path to the scanner.out executable
SCANNER_EXECUTABLE="./scanner.out"

# Define the path to the Testcases folder
TESTCASES_FOLDER="./Testcases"

# Find all input.txt files recursively in the Testcases folder
input_files=$(find "$TESTCASES_FOLDER" -name "input.txt")

# Iterate over each input.txt file
for input_file in $input_files; do
    # Extract the directory path of the input.txt file
    input_dir=$(dirname "$input_file")

    # Run the scanner.out executable for the input.txt file
    "$SCANNER_EXECUTABLE" ${input_dir}/input.txt

    # Move the generated output files to the current directory
    mv log.txt token.txt "$input_dir"

	echo "Scanned ${input_dir}"
done

rm scanner.out scanner.cpp