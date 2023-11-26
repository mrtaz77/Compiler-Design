#include<bits/stdc++.h>
#include"LinkedList.h"
using namespace std;

void print(LinkedList<pair<int,int>>& ll){
    cout << "<" ;
    int currPos = ll.currPos();
    for(int i=0;i<ll.length();i++){
        ll.setToPos(i);
        pair<int,int> q = ll.getValue();
        if(i == currPos)cout<< "| ";
        cout << "(" << q.first << " " << q.second << ")";
        if(i != ll.length() - 1)cout<< " ";
    }
    cout<<">";
    ll.setToPos(currPos);
}

LinkedList<pair<int,int>> genll(){
    LinkedList<pair<int,int>> ll;

    for(int i=0; i < 6; i++){
        if(i%2)ll.pushBack({i,i});
        else ll.push({i,i});
    }

    return ll;
}

int main(){
    LinkedList<pair<int,int>> ll;
    pair<int,int> p(1,2);

    for(int i=0;i<3;i++)ll.push({i,i});

    print(ll);
    cout<<endl;

    ll.push(p);

    print(ll);
    cout << endl;

    ll.push(p);

    print(ll);
    cout << endl;

    ll.next();

    print(ll);

    cout<<endl;

    ll.erase();

    print(ll);

    cout<<endl;

    ll.setToEnd();

    print(ll);
    cout<<endl;

    while(ll.length() > 1){
        pair<int,int> q = ll.erase();
        print(ll);
        cout <<" -> ("<< q.first << "," << q.second << ")\n";
    }

    LinkedList<pair<int,int>> llfunc = genll();

    print(llfunc);

    cout<<endl;

    ll = llfunc;

    print(ll);
    cout<<endl;

    ll.clear();

    print(ll);
    cout<<endl;

    for(int i=0;i<3;i++){
        ll.push({i,i});
        print(ll);
        cout<<endl;    
    }

    for(int i=0;i<3;i++){
        ll.erase();
        print(ll);
        cout<<endl;    
    }




}