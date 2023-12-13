flex -o scanner.cpp scanner.l
g++ scanner.cpp -lfl -o scanner.out
./scanner.out input.txt