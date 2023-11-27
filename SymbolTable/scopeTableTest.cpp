#include "ScopeTable.h"
using namespace std;

int main(){
    ScopeTable scopeTable("1",7);
    SymbolInfo symbols[] = {
        SymbolInfo(">=","RELOP"),
        SymbolInfo("<=","RELOP"),
        SymbolInfo("foo","FUNCTION"),
        SymbolInfo("num","Var"),
        SymbolInfo("j","VAR")
    };

    for(int i = 0 ; i < 5 ; i++)cout << boolalpha <<scopeTable.insert(symbols+i) << " ";

    cout << endl << scopeTable.print() << endl;

    for(int i = 0 ; i < 5 ; i++){
        cout << *scopeTable.lookUp((symbols + i)->getName()) << endl;
    }

    for(int i = 0 ; i < 5 ; i++){
        cout << boolalpha <<scopeTable.erase((symbols + i)->getName()) << endl;
        cout << scopeTable.print() ;
    }

}