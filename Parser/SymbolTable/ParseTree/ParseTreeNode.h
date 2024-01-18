#pragma once

#include<iostream>
#include<cstring>
#include<stdarg.h>

#include"Enums/DataEnum.h"
#include"LinkedList/LinkedList.h"

using namespace std;

class ParseTreeNode {
	unsigned long startOfNode;
	unsigned long endOfNode;
	
	ParseTreeNode* child;
	ParseTreeNode* sibling;

	string rule;

	Type_Spec type;

	bool functionDefined = false;
	bool functionDeclared = false;
	unsigned long definitionStart = 0;
	LinkedList<ParseTreeNode*> parameters;

	long arraySize;

public:

	ParseTreeNode(string rule = "", unsigned long startOfNode = 0, unsigned long endOfNode = 0, ParseTreeNode* child = nullptr, ParseTreeNode* sibling = nullptr) :
		startOfNode(startOfNode), 
		endOfNode(endOfNode), 
		child(child),
		sibling(sibling),
		rule(rule),
		type(Type_Spec::NO_TYPE_SPECIFIED),
		arraySize(-1) {}

	ParseTreeNode(const ParseTreeNode& other) :
		startOfNode(other.startOfNode), 
		endOfNode(other.endOfNode), 
		child(other.child),
		sibling(other.sibling),
		rule(other.rule),
		type(other.type),
		functionDeclared(other.functionDeclared),
		functionDefined(other.functionDefined),
		definitionStart(other.definitionStart),
		parameters(other.parameters),
		arraySize(other.arraySize) {}

	~ParseTreeNode() {
        delete child;
        delete sibling;
		startOfNode = 0;
		endOfNode = 0;
		parameters.clear();
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

	Type_Spec getType() const { 
		return type;
	}

	bool isFunctionDeclared() const { return functionDeclared; }
	bool isFunctionDefined() const { return functionDefined; }
	const LinkedList<ParseTreeNode*> getParameters() const { return parameters; }
	unsigned long getNumParameters() const { return parameters.length(); }
	unsigned long getDefinitionStart() const { return definitionStart; }

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

	void setType(Type_Spec newType) { 
		type = newType;
	}

	void setDefinitionStart(unsigned long lineNo){
		definitionStart = lineNo;
	}

	void setParameters(LinkedList<ParseTreeNode*> nodes) {
		parameters = nodes;
	}

	void setArraySize(long newArraySize) {
		arraySize = newArraySize;
	}

	void declareFunction(bool newFunctionDeclaration) {
		functionDeclared = newFunctionDeclaration;
	}

	void defineFunction(unsigned long lineNo = 0) {
		definitionStart = lineNo;
		functionDefined = functionDeclared = true;
	}

	void addParameter(ParseTreeNode* node) {
		parameters.pushBack(node);
	}

	void addParameters(LinkedList<ParseTreeNode*> nodes) {
		for(unsigned long i = 0; i < nodes.length(); i++){
			nodes.setToPos(i);
			addParameter(nodes.getValue());
		}
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