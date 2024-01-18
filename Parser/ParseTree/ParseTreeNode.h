#pragma once

#include<iostream>
#include<cstring>
#include<stdarg.h>

#include"Enums/FunctionEnum.h"
#include"Enums/DataEnum.h"

using namespace std;

class ParseTreeNode {
	unsigned long startOfNode;
	unsigned long endOfNode;
	
	ParseTreeNode* child;
	ParseTreeNode* sibling;

	string rule;

	Function_State state;
	Type_Spec type;

	long arraySize;

public:

	ParseTreeNode(string rule = "", unsigned long startOfNode = 0, unsigned long endOfNode = 0, ParseTreeNode* child = nullptr, ParseTreeNode* sibling = nullptr) :
		startOfNode(startOfNode), 
		endOfNode(endOfNode), 
		child(child),
		sibling(sibling),
		rule(rule),
		state(Function_State::NOT_A_FUNCTION),
		type(Type_Spec::NO_TYPE_SPECIFIED),
		arraySize(-1) {}

	ParseTreeNode(const ParseTreeNode& other) :
		startOfNode(other.startOfNode), 
		endOfNode(other.endOfNode), 
		child(other.child),
		sibling(other.sibling),
		rule(other.rule),
		state(other.state),
		type(other.type),
		arraySize(other.arraySize) {}

	~ParseTreeNode() {
        delete child;
        delete sibling;
		startOfNode = 0;
		endOfNode = 0;
    }

    unsigned long getStartOfNode() const {
        return startOfNode;
    }

    unsigned long getEndOfNode() const {
        return endOfNode;
    }

    ParseTreeNode* getChild() const {
        return child;
    }

    ParseTreeNode* getSibling() const {
        return sibling;
    }

    string getRule() const {
        return rule;
    }

	Function_State getState() const { 
		return state; 
	}

	Type_Spec getType() const { 
		return type;
	}

	bool isArray() const {
		return arraySize > -1;
	}

	long getArraySize() const {
		return arraySize;
	}

    void setStartOfNode(unsigned long start) {
        startOfNode = start;
    }

    void setEndOfNode(unsigned long end) {
        endOfNode = end;
    }

    void setChild(ParseTreeNode* newChild) {
        child = newChild;
    }

    void setSibling(ParseTreeNode* newSibling) {
        sibling = newSibling;
    }

    void setRule(const string& newRule) {
        rule = newRule;
    }

	void setState(Function_State newState) {
		state = newState;
	}

	void setType(Type_Spec newType) { 
		type = newType;
	}

	void setArraySize(long newArraySize) {
		arraySize = newArraySize;
	}

	ParseTreeNode* addChild(ParseTreeNode* child) {
		ParseTreeNode* itr = this->child;

		if(!itr) {
			this->child = child;
			return this;
		}

		while(itr->sibling) {
			itr = itr->sibling;
		}

		itr->sibling = child;

		return this;
	}

	string print(unsigned long height = 0){
		string out = "";

		for(unsigned long i = 0; i < height;i++) out.append(" ");

		out.append(rule);

		out.append("\t");

		out += "<Line: " + to_string(startOfNode) ;
		if(endOfNode) out += "-" + to_string(endOfNode) ;
		out += ">\n";

		for(ParseTreeNode* itr = child; itr != nullptr; itr = itr->sibling){
			out += itr->print(height + 1);
		}

		return out;
	}

	ParseTreeNode* addChildrenToNode(int childNo, ...) {
		va_list children;
		va_start(children, childNo);
		for (int i = 0; i < childNo; i++) addChild(va_arg(children,ParseTreeNode*));
		va_end(children);
		return this;
	}
};