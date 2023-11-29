#pragma once

#include"symbolInfo.h"

#define TAB "\t"
#define DEFAULT_BUCKET_SIZE 10

class ScopeTable{
    string id;
    ScopeTable* parentScope;
    uint64_t total_buckets;
    SymbolInfo** hashTable;
    int numOfChildren;

    uint64_t sdbm_hash(string str) {
        uint64_t hash = 0;
        uint64_t i = 0;
        uint64_t len = str.length();

        for (i = 0; i < len; i++)
        {
            hash = ((str[i]) + (hash << 6) + (hash << 16) - hash)%total_buckets;
        }

        return hash;
    }

public:
    ScopeTable(string id = "", uint64_t total_buckets = DEFAULT_BUCKET_SIZE,ScopeTable* parentScope = nullptr) :
        id(id),
        parentScope(parentScope), 
        total_buckets(total_buckets){
        hashTable = new SymbolInfo*[total_buckets];
        for(int i = 0; i < total_buckets; i++){
            hashTable[i] = nullptr;
        }
        numOfChildren = 0;
        cout << TAB << "ScopeTable# " << id << " created" << endl;
    }

    ~ScopeTable(){
        for(int i = 0; i < total_buckets; i++){
            SymbolInfo* current = hashTable[i];

            while(current != nullptr) {
                SymbolInfo* next = current->getNext();
                delete current;
                current = next;
            }
        }
        numOfChildren = 0;
        delete [] hashTable;
        total_buckets = 0;

        cout << TAB << "ScopeTable# " << id << " deleted" << endl;
    }

    ScopeTable(const ScopeTable& other) : 
        id(id),
        parentScope(parentScope), 
        total_buckets(total_buckets),
        numOfChildren(numOfChildren) {
        hashTable = new SymbolInfo*[total_buckets];
        for(int i = 0; i < other.total_buckets; i++){
            hashTable[i] = other.hashTable[i];
        }
    }

    void operator=(const ScopeTable& other){
        this->id = other.id;
        this->total_buckets = other.total_buckets;
        this->parentScope = other.parentScope;
        this->numOfChildren = other.numOfChildren;
        this->hashTable = new SymbolInfo*[this->total_buckets];
        for(int i = 0; i < other.total_buckets; i++){
            hashTable[i] = other.hashTable[i];
        }
    }

    string getId() { return id; }
    void setId(string id) { this->id = id; }

    uint64_t getNumBuckets() { return total_buckets; }

    int getNumOfChildren() const { return numOfChildren; }
    void setNumOfChildren(int numOfChildren) { this->numOfChildren = numOfChildren; }

    ScopeTable* getParentScope() { return parentScope; }
    void setParentScope(ScopeTable *parentScope) { this->parentScope = parentScope; }

    SymbolInfo* lookUp(string name){
        uint64_t hash = sdbm_hash(name);

        SymbolInfo *itr = hashTable[hash];

        while(itr != nullptr) {
            if(itr->getName() == name)return itr;
            itr = itr->getNext();
        }
        
        return nullptr;
    }

    uint64_t getBucketIndex(string name) {
        if(lookUp(name) != nullptr)return sdbm_hash(name) + 1;
        else return -1;
    }

    long getPositionInBucket(string name) {
        uint64_t hash = sdbm_hash(name);

        SymbolInfo *itr = hashTable[hash];

        long i = 1;
        while(itr != nullptr) {
            if(itr->getName() == name)return i;
            itr = itr->getNext();
            i += 1;
        }

        return -1;
    }

    bool insert(SymbolInfo* symbol){
        string name = symbol->getName();
        uint64_t hash = sdbm_hash(name);

        SymbolInfo *itr = hashTable[hash];
        SymbolInfo *prev = nullptr;

        while(itr != nullptr) {
            if(itr->getName() == name)return false;
            prev = itr;
            itr = itr->getNext();
        }

        if(prev == nullptr)hashTable[hash] = symbol;
        else prev->setNext(symbol);

        return true;
    }

    bool erase(string name){

        uint64_t hash = sdbm_hash(name);

        SymbolInfo *itr = hashTable[hash];
        SymbolInfo *prev = nullptr;

        while(itr != nullptr) {
            if(itr->getName() == name){
                if(prev != nullptr)prev->setNext(itr->getNext());
                else hashTable[hash] = itr->getNext();

                delete itr;
                return true;
            }
            prev = itr;
            itr = itr->getNext();
        }
        return false;
    }

    string print(){
        string str = "";

        str += TAB + string("ScopeTable# ") + id + "\n";

        int i ;
        for(i = 1; i <= total_buckets; i++){
            str += TAB + to_string(i);

            SymbolInfo *itr = hashTable[i-1];

            while(itr != nullptr){
                str += " --> " + itr->print();
                itr = itr->getNext();
            }
            str += "\n";
        }

        return str; 
    }
};