#include<iostream>
#include<cstring>
using namespace std;

class SymbolInfo{
    string name;
    string type;
    SymbolInfo* next;

public:
    SymbolInfo(string name, string type,SymbolInfo* next=NULL) :
        name(name),
        type(type),
        next(next) { }

    string getName() const { return name; }
    string getType() const { return type; }
    SymbolInfo* getNext() const { return next; }

    void setName(string name) { this->name = name; }
    void setType(string type) { this->type = type; }
    void setNext(SymbolInfo* next) { this->next = next; }


    SymbolInfo(const SymbolInfo& other) :
        name(other.name), 
        type(other.type), 
        next(other.next) { }

    ~SymbolInfo() {
        next = NULL;
    }

    void operator=(const SymbolInfo& other) { 
        name = other.name; 
        type = other.type; 
        next = other.next; 
    }

    bool operator==(const SymbolInfo& other) const { return name == other.name ; }

    friend ostream& operator<<(ostream& out, const SymbolInfo& symbolInfo){
        out << "(" << symbolInfo.name << "," << symbolInfo.type << ")";
        return out;
    }

    string print(){
        return "(" + name + "," + type + ")";
    }
};