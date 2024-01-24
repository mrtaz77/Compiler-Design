# Compiler-Design
Road to a working c++ compiler

## Navigation
**Offline 1**
- [SymbolTable](/SymbolTable/)
    - [Specification](/Specifications/Symbol%20Table%20Implementation.pdf)
    - [SymbolInfo](/SymbolTable/SymbolInfo.h) : <name , type>
    - [ScopeTable](/SymbolTable/ScopeTable.h) : A hash table implemented using seperate chaining
    - [SymbolTable](/SymbolTable/SymbolTable.h) : A list of scopetables

**Offline 2**
- [Lexical Analysis](/Lexical%20Analyzer/)
	- [Specification](/Specifications/spec.pdf)
	- [Scanner made using flex](/Lexical%20Analyzer/scanner.l)
	- [Bash script](/Lexical%20Analyzer/command.sh)

**Offline 3**
- [Syntax and Semantic Analysis](/Parser/)
	- [Specification](/Specifications/CSE310_July_2023_YACC_Assignment_Spec.pdf)
	- [Grammar rules](/Specifications/BisonAssignmentGrammar.PDF)
	- Useful Links
		- **Usage YYLTYPE yylloc**
			- [Location Type](https://www.gnu.org/software/bison/manual/html_node/Location-Type.html)
		- **Usage %code**
			- [Prologue alternatives](https://www.gnu.org/software/bison/manual/html_node/Prologue-Alternatives.html)
			- [%code summary](https://www.gnu.org/software/bison/manual/html_node/_0025code-Summary.html)
		- **Usage %printer**
			- [Printing Semantic Values](https://www.gnu.org/software/bison/manual/html_node/Printer-Decl.html#:~:text=The%20%25printer%20directive%20defines%20code,(see%20Freeing%20Discarded%20Symbols).&text=Invoke%20the%20braced%20code%20whenever%20the%20parser%20displays%20one%20of%20the%20symbols%20.)
