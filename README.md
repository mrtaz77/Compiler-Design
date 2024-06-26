# Compiler-Design
Road to a working c compiler
- [**Offline 1 SymbolTable**](#offline-1)
- [**Offline 2 Lexical Analyzer**](#offline-2)
- [**Offline 3 Parser**](#offline-3)
- [**Offline 4 Intermediate Code Generator**](#offline-4)

## Dependency
flex 2.6.4 and bison 3.8.2
```
sudo apt-get update 
sudo apt install flex
sudo apt install bison
```

## Offline 1
- [SymbolTable](/SymbolTable/)
    - [Specification](/Specifications/Symbol%20Table%20Implementation.pdf)
    - [SymbolInfo](/SymbolTable/SymbolInfo.h) : <name , type>
    - [ScopeTable](/SymbolTable/ScopeTable.h) : A hash table implemented using seperate chaining
    - [SymbolTable](/SymbolTable/SymbolTable.h) : A list of scopetables
- __How to run__
	- Open a "input.txt" in the directory of [MainFileIO.cpp](/SymbolTable/MainFileIO.cpp)
	- Insert commands as per the [spec](/Specifications/Symbol%20Table%20Implementation.pdf) 
	- Run the [MainFileIO.cpp](/SymbolTable/MainFileIO.cpp)
- __Challenges__
	- Extensive usage of pointers. 
	- As long as any memory allocated by new is deleted in the correct order everything works.
	- Carefully tokenized input file based on whitespace.
	- The sdbm hash specified [here](http://www.cse.yorku.ca/~oz/hash.html) uses unsigned long as return data type. This leads to error as the resulting hash may go beyond the range of unsigned long. 
	**Used unsigned long long instead.**
```cpp
unsigned long long sdbm_hash(string str) {
        unsigned long long hash = 0;
        unsigned long long i = 0;
        unsigned long long len = str.length();

        for (i = 0; i < len; i++)
        {
            hash = ((str[i]) + (hash << 6) + (hash << 16) - hash);
        }

        return hash%total_buckets;
    }
```

## Offline 2
- [Lexical Analysis](/Lexical%20Analyzer/)
	- [Specification](/Specifications/spec.pdf)
	- [Scanner made using flex](/Lexical%20Analyzer/scanner.l)
- __How to run__
	- Navigate to the [folder](/Lexical%20Analyzer/) 
	- Open a new file with the name "input.txt" and paste the file to be scanned.
	- Run the [script](/Lexical%20Analyzer/command.sh)

## Offline 3
- [Syntax and Semantic Analysis](/Parser/)
	- [Specification](/Specifications/CSE310_July_2023_YACC_Assignment_Spec.pdf)
	- [Grammar rules](/Specifications/BisonAssignmentGrammar.PDF)
	- [Parser made using bison](/Parser/parser.y)
	- [Scanner modified for parsing](/Parser/scanner.l)
- Useful Links
	- **Usage YYLTYPE yylloc**
		- [Location Type](https://www.gnu.org/software/bison/manual/html_node/Location-Type.html)
		- [%locations](https://www.youtube.com/watch?v=FSS6FrSNVis)
	- **Usage %code**
		- [Prologue alternatives](https://www.gnu.org/software/bison/manual/html_node/Prologue-Alternatives.html)
		- [%code summary](https://www.gnu.org/software/bison/manual/html_node/_0025code-Summary.html)
	- **Usage %printer**
		- [Printing Semantic Values](https://www.gnu.org/software/bison/manual/html_node/Printer-Decl.html#:~:text=The%20%25printer%20directive%20defines%20code,(see%20Freeing%20Discarded%20Symbols).&text=Invoke%20the%20braced%20code%20whenever%20the%20parser%20displays%20one%20of%20the%20symbols%20.)
- __How to run__
	- Navigate to the [folder](/Parser/) 
	- Open a new file with the name "input.c" and paste the file to be scanned.
	- Run the [script](/Parser/command.sh)


## Offline 4
- [Intermediate Code Generation](/Intermediate%20Code%20Generation/)
	- [Specification](/Specifications/CSE_310_July_2023_ICG_Spec.pdf)
	- [Parser modified for ICG](/Intermediate%20Code%20Generation/parser.y)
	- [ICG](/Intermediate%20Code%20Generation/IcgUtil.cpp)
	- [Optimizer](/Intermediate%20Code%20Generation/OptimalASMUtil.h)
- __How to run__
	- Navigate to the [folder](/Intermediate%20Code%20Generation/) 
	- Open a new file with the name "input.c" and paste the file to be scanned.
	- Run the [script](/Intermediate%20Code%20Generation/command.sh)