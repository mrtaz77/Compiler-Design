#pragma once

#include<stdio.h>
#include<stdlib.h>
#include<cstring>
#include<vector>
using namespace std;

FILE *optimized_asm_out;

bool isValidAsmFile(string fileName){
	size_t dotPosition = fileName.find_last_of('.');

	if (dotPosition == string::npos || fileName.substr(dotPosition) != ".asm") {
		printf("Invalid file extension. Please provide a .asm file.");
		return false;
	}else {
		FILE *fin = fopen(fileName.c_str(),"r");
		if(fin==NULL){ 
			printf("Cannot open specified file\n");
			return false;
		}else {
			fclose(fin);
			return true;
		}
	}
}

pair<string, string> getOperandsFromMovLine(const string& movLine) {
    size_t movPos = movLine.find("MOV") + 4;
    size_t commaPos = movLine.find(",");

	return make_pair(movLine.substr(movPos, commaPos - movPos), movLine.substr(commaPos + 2,movLine.length() - 1 - commaPos - 2));
}

bool areConsecutiveMovs(const string& currentLine, const string& nextLine) {
	return currentLine.find("MOV") != string::npos &&
        nextLine.find("MOV") != string::npos &&
        currentLine.find(",") != string::npos &&
        nextLine.find(",") != string::npos;
}



bool areConsecutiveMovsBetweenSameOperands(const string& currentLine, const string& nextLine) {
    if (areConsecutiveMovs(currentLine,nextLine)) {

        auto currentOperands = getOperandsFromMovLine(currentLine);
        auto nextOperands = getOperandsFromMovLine(nextLine);

		return (currentOperands.first == nextOperands.second 
		&& currentOperands.second == nextOperands.first) ;
	}

    return false;
}

bool areConsecutiveMovsToSameOperand(const string& currentLine, const string& nextLine) {
    if (areConsecutiveMovs(currentLine,nextLine)) {

        auto currentOperands = getOperandsFromMovLine(currentLine);
        auto nextOperands = getOperandsFromMovLine(nextLine);

		return (currentOperands.first == nextOperands.first) ;
	}

    return false;
}

bool isRedundantAddOrSub(const string& currentLine) {
	if((currentLine.find("ADD") != string::npos ||
	currentLine.find("SUB") != string::npos) &&
	currentLine.find(",") != string::npos ) {
		size_t commaPos = currentLine.find(",");
		string substrAfterComma = currentLine.substr(commaPos + 1);  // Extract substring after comma

        return atoi(substrAfterComma.c_str()) == 0;
	}
}

bool areConsecutivePushPopOfSameOperand(const string& currentLine, const string& nextLine) {
	if(currentLine.find("PUSH") != string::npos &&
    nextLine.find("POP") != string::npos) {
		size_t pushOpLoc = currentLine.find("PUSH") + 5;
		size_t popOpLoc = nextLine.find("POP") + 4;

		string pushOp = currentLine.substr(pushOpLoc,currentLine.length() - 1 - pushOpLoc);
		string popOp = nextLine.substr(popOpLoc,nextLine.length() - 1 - popOpLoc);

		return pushOp == popOp;
	}
}


void writeOptimizedCodeToFile(vector<string>& lines) {
	for(auto line : lines) {
		fprintf(optimized_asm_out, "%s", line.c_str());
	}
}

void optimizeASMLines(vector<string>& lines) {
	cout << "Before optimization lines : " << lines.size() << endl;

	for(int i=0; i<lines.size() - 1; i++) {
		// cout << "Lines " << i << " and " << (i+1) << endl;
		string currentLine = lines[i];
        string nextLine = lines[i + 1];

        if (areConsecutiveMovsBetweenSameOperands(currentLine, nextLine)) {
            lines.erase(lines.begin() + i + 1);
            --i;
        }

		else if(areConsecutiveMovsToSameOperand(currentLine, nextLine)) {
			lines.erase(lines.begin() + i);
			--i;
		}

		else if(isRedundantAddOrSub(currentLine)) {
			lines.erase(lines.begin() + i);
			--i;
		}

		else if(areConsecutivePushPopOfSameOperand(currentLine, nextLine)) {
			lines.erase(lines.begin() + i);
			lines.erase(lines.begin() + i);
			--i;
		}
	}
	cout << "After optimization lines : " << lines.size() << endl;

	writeOptimizedCodeToFile(lines);
}

void peepHoleOptimization(string asm_file, string optimized_asm_file){
	FILE *asm_in;

	bool isValid = isValidAsmFile(asm_file);

	if(!isValid)return;
	asm_in = fopen(asm_file.c_str(), "r");

	vector<string> lines;
	char buffer[1024];

	while (fgets(buffer, sizeof(buffer), asm_in) != nullptr) {
		lines.push_back(buffer);
	}

	fclose(asm_in);

	optimized_asm_out = fopen(optimized_asm_file.c_str(), "w");

	optimizeASMLines(lines);

	fclose(optimized_asm_out);
}

