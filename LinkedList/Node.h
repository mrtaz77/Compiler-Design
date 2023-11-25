#include<iostream>
using namespace std;

template<typename E>
class Node{
    E element;
    Node<E> *next;

public:

    Node(E element, Node<E>* next) : element(element) , next(next) {}
    
    Node(Node<E>* next) : next(next) { }

    E getElement() const { return element; }
    void setElement(E element) { this->element = element; }

    Node<E>* getNext() const { return next; }
    void setNext(Node<E>* next) { this->next = next; }

    ~Node() {
        element = NULL;
        this->next = NULL;
    }

};