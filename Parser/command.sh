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
./parser input.c
rm y.o l.o
rm parser.tab.c parser.tab.h lex.yy.c