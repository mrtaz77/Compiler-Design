#pragma once

#include"ScopeTable.h"
#include<cstring>

class SymbolTable{
    ScopeTable* currentScope;
	unsigned long currentScopeTableId;

    ScopeTable* getScopeOfSymbol(string name){
        ScopeTable* itr = currentScope;
        SymbolInfo* symbol ;

        while(itr != nullptr){
            symbol = itr->lookUp(name);
            if(symbol != nullptr)return itr;
            else itr = itr->getParentScope();
        }
        return nullptr;
    }

public:

    SymbolTable(int bucketSize){
		currentScopeTableId = 0;
        currentScope = new ScopeTable(to_string(++currentScopeTableId), bucketSize);
		currentScope->setCurrentOffset(0);
	}

    ~SymbolTable(){
        while(currentScope != nullptr){
            ScopeTable* temp = currentScope;
            currentScope = currentScope->getParentScope();
            delete temp;
        }
    }

    SymbolTable(SymbolTable& other) {
        currentScope = other.currentScope;
    }

    void operator=(SymbolTable& other) {
        currentScope = other.currentScope;
    }   

    string getCurrentScopeId() { return currentScope->getId(); }

    void enterScope(){
        string id = to_string(++currentScopeTableId);

        int childId = currentScope->getNumOfChildren() + 1;

        ScopeTable* newScope = new ScopeTable(id,currentScope->getNumBuckets(),currentScope);

        currentScope->setNumOfChildren(childId);

		if(currentScope->getParentScope() != nullptr)newScope->setCurrentOffset(currentScope->getCurrentOffset());

        currentScope = newScope;
    }


    bool exitScope(){
        // never exit the initial scope
        if(currentScope->getParentScope() == nullptr)return false;
        ScopeTable* temp = currentScope;
        currentScope = currentScope->getParentScope();
		currentScope->setCurrentOffset(temp->getCurrentOffset());
        delete temp;
        return true;
    }

    bool insert(SymbolInfo* symbol){
        return currentScope->insert(symbol);
    }

    bool erase(string name){
        return currentScope->erase(name);
    }

    SymbolInfo* lookUp(string name){
        ScopeTable* itr = getScopeOfSymbol(name);
        if(itr != nullptr)return itr->lookUp(name);
        else return nullptr;
    }

    string getScopeIdOfSymbol(string name){
        ScopeTable* itr = getScopeOfSymbol(name);
        if(itr != nullptr)return itr->getId();
        else return "";
    }

    long getBucketIndex(string name){
        ScopeTable* itr = getScopeOfSymbol(name);
        if(itr != nullptr)return itr->getBucketIndex(name);
        else return -1;
    }

    long getPositionInBucket(string name){
        ScopeTable* itr = getScopeOfSymbol(name);
        if(itr != nullptr)return itr->getPositionInBucket(name);
        else return -1;
    }

    string printCurrentScope(){
        return currentScope->print();
    }

    string printAllScopes(){
        string str = "";

        ScopeTable* itr = currentScope;

        while(itr != nullptr){
            str += itr->print();
            itr = itr->getParentScope();
        }

        return str;
    }

	vector<SymbolInfo*> getSortedSymbolInfosOfCurrentScope() {
		return currentScope->getSortedSymbolInfoVector();
	}
};