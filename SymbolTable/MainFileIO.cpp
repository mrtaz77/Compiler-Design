#include<iostream>
#include<cstring>
#include<fstream>
#include<sstream>
#include"SymbolTable.h"

using namespace std;

int numOftoken(string& line,char delimiter){
    istringstream iss(line);
    string token;
    int count = 0;

    while (getline(iss, token, delimiter)) {
        count++;
    }

    return count;
}

int main(){

    // freopen("input.txt", "r", stdin);
    // freopen("output.txt", "w", stdout);

    int bucketSize;
    cin >> bucketSize >> ws;

    SymbolTable table(bucketSize);

    cout << SPACE << "ScopeTable# "  << table.getCurrentScopeId() << " created" << endl;

    char cmd;
    int cmdLine = 0;
    string line;
    while (getline(cin, line)) {
        istringstream iss(line);
        char cmd;
        cmdLine++;

        cout << "Cmd " << cmdLine << ": "<< line << endl;

        if (!(iss >> cmd)) {
            cout << SPACE << "Error reading command." << endl;
            continue;
        }

        switch (cmd) {
            case 'I': {
                string name, type;
                if (!(iss >> name >> type) || numOftoken(line,' ') != 3) {
                    cout << SPACE << "Wrong number of arguments for the command " << cmd << endl;
                } else {
                    auto flag = table.insert(new SymbolInfo(name, type));
                    if(flag){
                        cout << SPACE
                            << "Inserted  at position <" 
                            << table.getBucketIndex(name)
                            << ", " 
                            << table.getPositionInBucket(name)
                            << "> of ScopeTable# "
                            << table.getScopeIdOfSymbol(name)
                            << endl;
                    }else{
                        cout << SPACE
                            << "'"
                            << name 
                            << "' already exists in the current ScopeTable# "
                            << table.getScopeIdOfSymbol(name)
                            << endl; 
                    }
                }
            }
            break;

            case 'L': {
                string name;
                if (!(iss >> name) || numOftoken(line,' ') != 2) {
                    cout << SPACE << "Wrong number of arugments for the command " << cmd << endl;
                } else {
                    auto found = table.lookUp(name);
                    if(found){
                        cout << SPACE
                            << "'"
                            << name 
                            << "' found at position <"
                            << table.getBucketIndex(name)
                            << ", " 
                            << table.getPositionInBucket(name)
                            << "> of ScopeTable# "
                            << table.getScopeIdOfSymbol(name)
                            << endl;
                    }else{
                        cout << SPACE
                            << "'"
                            << name 
                            << "' not found in any of the ScopeTables"
                            << endl;
                    }
                }
            }
            break;

            case 'D': {
                string name;
                if (!(iss >> name) || numOftoken(line,' ') != 2) {
                    cout << SPACE << "Wrong number of arugments for the command " << cmd << endl;
                } else {
                    long row = table.getBucketIndex(name);
                    long col = table.getPositionInBucket(name);
                    string scopeId = table.getScopeIdOfSymbol(name);
                    if(table.erase(name)){
                        cout << SPACE
                            << "Deleted '"
                            << name 
                            << "' from position <"
                            << row
                            << ", " 
                            << col
                            << "> of ScopeTable# "
                            << scopeId
                            << endl;
                    }else{
                        cout << SPACE
                            << "Not found in the current ScopeTable# "
                            << table.getCurrentScopeId()
                            << endl;
                    }
                }
            }
            break;

            case 'P': {
                char printOption;
                if (!(iss >> printOption)  || numOftoken(line,' ') != 2) {
                    cout << SPACE << "Wrong number of arguments for the command " << cmd << endl;
                } else {
                    if (printOption == 'A') {
                        cout << table.printAllScopes() ;
                    } else if (printOption == 'C'){
                        cout << table.printCurrentScope() ;
                    } else{
                        cout << SPACE << "Invalid argument for the command " << cmd << endl;
                    }
                }
            }
            break;

            case 'S': {
                if(numOftoken(line,' ') != 1){
                    cout << SPACE << "Wrong number of arguments for the command " << cmd << endl;
                }else {
                    table.enterScope();
                    cout << SPACE 
                        << "ScopeTable# " 
                        << table.getCurrentScopeId() 
                        << " created" 
                        << endl;
                }
            }
            break;

            case 'E': {
                if(numOftoken(line,' ') != 1){
                    cout << SPACE << "Wrong number of arguments for the command " << cmd << endl;
                }else {
                    auto id = table.getCurrentScopeId();
                    auto flag = table.exitScope();
                    if(flag){
                        cout << SPACE 
                            << "ScopeTable# "
                            << id 
                            << " deleted"
                            << endl;
                    }else {
                        cout << SPACE
                            << "ScopeTable# "
                            << id
                            << " cannot be deleted"
                            << endl;

                    }
                }
            }
            break;

            case 'Q': {
                if(numOftoken(line,' ') != 1){
                    cout << SPACE << "Wrong number of arguments for the command " << cmd << endl;
                }else {
                    string id;
                    do{
                        id = table.getCurrentScopeId();
                        table.exitScope();
                        cout << SPACE 
                            << "ScopeTable# "
                            << id 
                            << " deleted"
                            << endl;
                    }while(id != "1");
                }
            }
            break;
        }
    }
}