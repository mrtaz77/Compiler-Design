#pragma once

#include<iostream>

#include"ParseTree/ParseTreeNode.h"

using namespace std;

class SymbolInfo{
    string name;
    string type;
    SymbolInfo* next;
	ParseTreeNode* node;

public:
    SymbolInfo(string name = "", string type = "",SymbolInfo* next = nullptr,ParseTreeNode* node = nullptr) :
        name(name),
        type(type),
        next(next),
		node(node) { }

    string getName() const { return name; }
    string getType() const { return type; }
    SymbolInfo* getNext() const { return next; }
	ParseTreeNode* getNode() const { return node; }

    void setName(string name) { this->name = name; }
    void setType(string type) { this->type = type; }
    void setNext(SymbolInfo* next) { this->next = next; }
	void setNode(ParseTreeNode* node) { this->node = node; }


    SymbolInfo(const SymbolInfo& other) :
        name(other.name), 
        type(other.type), 
        next(other.next),
		node(other.node) { }

    ~SymbolInfo() {
    }

    void operator=(const SymbolInfo& other) { 
        name = other.name; 
        type = other.type; 
        next = other.next;
		node = other.node;
    }

    bool operator==(const SymbolInfo& other) const { return name == other.name ; }

    friend ostream& operator<<(ostream& out, const SymbolInfo& symbolInfo){
        out << "(" << symbolInfo.name << "," << symbolInfo.type << ")";
        return out;
    }

    string print(){
        return "<" + name + "," + type + ">";
    }
};