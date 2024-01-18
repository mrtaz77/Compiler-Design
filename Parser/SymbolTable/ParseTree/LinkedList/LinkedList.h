#pragma once

#include <iostream>
#include <cassert>
#include "Node.h"
using namespace std;

template<typename E>
class LinkedList{
    Node<E>* current;
    Node<E>* head;
    Node<E>* tail;
    unsigned long size;

public:

    LinkedList(){
        current = head = tail = new Node<E>;
        size = 0;
    }

    ~LinkedList(){
        size = 0;
        while(head != nullptr){
            current = head;
            head = head->getNext();
            delete current;
        }
    }

    LinkedList(const LinkedList& ll){
        this->size = ll.size;
        this->head = ll.head;
        this->current = ll.current;
        this->tail = ll.tail;
    }

    void operator=(const LinkedList& ll){
        this->size = ll.size;
        this->head = ll.head;
        this->current = ll.current;
        this->tail = ll.tail;
    }

    void clear() { 
        while(head != nullptr) { 
            current = head; 
            head = head->getNext(); 
            delete current;
        }
        current = head = tail = new Node<E>;
        size = 0;
    }

    void push(const E& item) {
        Node<E> *newNode = new Node<E>(item,current->getNext());
        current->setNext(newNode);
        if(tail == current)tail = current->getNext();
        size++;
    }

    void prev(){
        if(current != head){
            Node<E>* temp = head;
            while(temp->getNext() != current)temp = temp->getNext();
            current = temp;
        }
    }

    void next(){
        if(current != tail && size != 0){
            current = current->getNext();
        }
    }

    void setToEnd(){
        if(current->getNext() != nullptr)
            while(current->getNext() != tail)
                current = current->getNext();
    }

    void setToBegin(){
        current = head;
    }

    int length() const { return size; }

    void setToPos(int pos){
        if(pos < 0 || pos >= size)return;
        current = head;
        for(int i = 0; i < pos; i++)current = current->getNext();
    }

    int currPos() {
        int currentPos = 0;
        Node<E>* temp = head;
        while(temp != current){
            temp = temp->getNext();
            currentPos ++ ;
        }
        return currentPos;
    }

    E getValue() {
        assert(size > 0);
        return current->getNext()->getElement();
    }

    int find(const E& element) {
        int pos = 0;
        Node<E>* temp = head;
        while(pos < size){
            if(temp->getElement() == element)return pos;
            pos++;
            temp = temp->getNext();
        }
        return -1;
    }

    E erase(){
        assert(size > 0);
        E output = current->getNext()->getElement();
        if(tail == current->getNext()) tail = current;
        Node<E>* temp = current->getNext();
        current->setNext(current->getNext()->getNext());
        delete temp;
        size--;
        if(tail == current)prev();
        return output;
    }

    void pushBack(const E& item){
        Node<E> *newNode = new Node<E>(item,tail->getNext());
        tail->setNext(newNode);
        tail = tail->getNext();
        size++;
    }
};