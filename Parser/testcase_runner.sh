#!/bin/bash

bison --header parser.y
echo 'Generated the parser C file as well the header file'
g++ -w -c -o y.o parser.tab.c
echo 'Generated the parser object file'
flex scanner.l
echo 'Generated the scanner C file'
g++ -w -c -o l.o lex.yy.c
# if the above command doesn't work try 
# g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'Generated the scanner object file'
g++ y.o l.o -lfl -o parser
echo 'All ready, running'

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
    ./parser "$input_file"

    # Move all generated output files (both .txt and .asm) to the respective folder
    mv *.txt "Sample Output/$filename/"

	echo "parsed "$filename" successfully"
done

rm y.o l.o parser
rm parser.tab.c parser.tab.h lex.yy.c
