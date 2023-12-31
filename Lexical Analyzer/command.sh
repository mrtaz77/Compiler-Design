#!/bin/bash

flex -o scanner.cpp scanner.l
g++ scanner.cpp -lfl -o scanner.out
./scanner.out input.txt
rm scanner.out
rm scanner.cpp