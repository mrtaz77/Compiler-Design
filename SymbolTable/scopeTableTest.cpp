#include "ScopeTable.h"
using namespace std;

int main(){
    ScopeTable scopeTable("1",NULL,7);
    SymbolInfo symbols[] = {
        SymbolInfo("foo","FUNCTION"),
        SymbolInfo("23","NUMBER"),
        SymbolInfo("i","VAR"),
        SymbolInfo("==","EQU"),
        SymbolInfo("j","VAR")
    };

    for(int i = 0 ; i < 5 ; i++)cout << boolalpha <<scopeTable.insert(symbols+i) << " ";

    cout << endl << scopeTable << endl;

    for(int i = 0 ; i < 5 ; i++){
        cout << *scopeTable.lookUp((symbols + i)->getName()) << endl;
    }

    for(int i = 0 ; i < 5 ; i++){
        cout << boolalpha <<scopeTable.erase((symbols + i)->getName()) << endl;
        cout << scopeTable ;
    }

}