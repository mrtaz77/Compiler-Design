#pragma once

#include<iostream>
#include<cstring>
#include<stdarg.h>
#include<vector>

#include"Enums/DataEnum.h"

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
	vector<ParseTreeNode*> parameters;

	long arraySize;
	string val;

	long offset;
	bool isParameter;
	string scope;

public:

	ParseTreeNode(string rule = "", unsigned long startOfNode = 0, unsigned long endOfNode = 0,long offset = -1, bool isParmam = 0, ParseTreeNode* child = nullptr, ParseTreeNode* sibling = nullptr) :
		startOfNode(startOfNode), 
		endOfNode(endOfNode), 
		child(child),
		sibling(sibling),
		rule(rule),
		type(Type_Spec::NAT),
		arraySize(-1),
		val(""),
		offset(offset),
		isParameter(isParameter) {}

	ParseTreeNode(const ParseTreeNode& other) :
		startOfNode(other.startOfNode), 
		endOfNode(other.endOfNode), 
		child(other.child),
		sibling(other.sibling),
		rule(other.rule),
		type(other.type),
		functionDeclared(other.functionDeclared),
		functionDefined(other.functionDefined),
		parameters(other.parameters),
		arraySize(other.arraySize),
		val(other.val),
		offset(other.offset),
		isParameter(other.isParameter),
		scope(other.scope) {}

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

	string getVal() { return val; }

	bool isFunctionDeclared() const { return functionDeclared; }
	bool isFunctionDefined() const { return functionDefined; }
	vector<ParseTreeNode*> getParameters() { return parameters; }
	unsigned long getNumParameters() const { return parameters.size(); }

	bool isArray() const {
		return arraySize >= 0;
	}

	long getArraySize() const {
		return arraySize;
	}

	long getOffset() const { return offset; }

	unsigned long getNumOfChildren() {
		unsigned long i = 0;
		for(ParseTreeNode* itr = child; itr != nullptr; itr = itr->sibling)i++;
		return i;
	}

	bool isParam() const { return isParameter; }

	string getScope() const { return scope; }

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

	void setParameters(vector<ParseTreeNode*> parameters) {
		this->parameters = parameters;
	}

	void setArraySize(long newArraySize) {
		arraySize = newArraySize;
	}

	void setVal(string value) { val = value; }

	void declareFunction(bool newFunctionDeclaration) {
		functionDeclared = newFunctionDeclaration;
	}

	void defineFunction(bool newFunctionDefination) {
		functionDefined = functionDeclared = newFunctionDefination;
	}

	void addParameter(ParseTreeNode* node) {
		parameters.push_back(node);
	}

	void addParameters(vector<ParseTreeNode*> nodes) {
		for(unsigned long i = 0; i < nodes.size(); i++){
			addParameter(nodes[i]);
		}
	}

	void setOffset(long offset) { this->offset = offset; }

	void setParam(bool isParameter) { this->isParameter = isParameter; }

	void setScope(string scope) { this->scope = scope; }

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

	ParseTreeNode* getNthChild(unsigned long childNo) {
		int index = 1;
		ParseTreeNode* itr;
		for(itr = child; itr != nullptr && index < childNo; itr = itr->sibling){
			index++;
		}
		return itr;
	}

	unsigned long getParameterWidth() {
		if(!functionDefined) return -1;
		return 2 * getNumParameters();
	}
};