#pragma once

#include<iostream>
#include<cstring>

using namespace std;

class ParseTreeNode {
	unsigned long startOfNode;
	unsigned long endOfNode;
	
	ParseTreeNode* child;
	ParseTreeNode* sibling;

	string rule;

public:

	ParseTreeNode(string rule = "", unsigned long startOfNode = 0, unsigned long endOfNode = 0, ParseTreeNode* child = nullptr, ParseTreeNode* sibling = nullptr) :
		startOfNode(startOfNode), 
		endOfNode(endOfNode), 
		child(child),
		sibling(sibling),
		rule(rule) {}

	ParseTreeNode(const ParseTreeNode& other) :
		startOfNode(other.startOfNode), 
		endOfNode(other.endOfNode), 
		child(other.child),
		sibling(other.sibling),
		rule(other.rule) {}

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

		for(unsigned int i = 0; i < height;i++) out.append(" ");

		out.append(rule);

		out.append(" \t");

		out += "<Line: " + to_string(startOfNode) ;
		if(endOfNode) out += "-" + to_string(endOfNode) ;
		out += ">\n";

		for(ParseTreeNode* itr = child; itr != nullptr; itr = itr->sibling){
			out += itr->print(height + 1);
		}

		return out;
	}
};