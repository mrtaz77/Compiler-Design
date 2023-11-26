#include<iostream>
using namespace std;

template<class E1,class E2>
class myPair{
public:
    E1 first;
    E2 second;

    myPair(const E1& first,const E2& second){
        this->first = first;
        this->second = second;
    }

    myPair(const myPair& pair) : first(pair.first), second(pair.second) {}
    
    void operator=(const myPair& pair){
        this->first = pair.first;
        this->second = pair.second;
    }

    ~myPair(){
    }

    friend ostream& operator<<(ostream& out,const myPair& pair){
        out << "(" << pair.first << "," << pair.second << ")";
        return out;
    }
};

