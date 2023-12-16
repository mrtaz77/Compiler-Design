#include<iostream>
#include<cstring>
using namespace std;

string extractCharacter(string lexeme) {
    if(lexeme.length() == 3) return lexeme.substr(1, lexeme.length() - 2);
    if (lexeme.length() == 4 && lexeme[0] == '\'' && lexeme[1] == '\\' && lexeme[lexeme.length() - 1] == '\'') {
        char backslashConstant = lexeme[2];
        switch (backslashConstant) {
            case 'a':
                return "\a";
            case 'b':
                return "\b";
            case 'f':
                return "\f";
            case 'n':
                return "\n";
            case 'r':
                return "\r";
            case 't':
                return "\t";
            case 'v':
                return "\v";
            case '0':
                return "\0";
            case '?':
                return "\?";
            default:
                return "Unknown";
        }
    }

    return lexeme.substr(1, lexeme.length() - 2);
}

unsigned long long SDBMHash(string str) {
	unsigned long long hash = 0;
	unsigned long long i = 0;
	unsigned long long len = str.length();

	for (i = 0; i < len; i++)
	{
		hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
	}

	return hash;
}


int main(){
    string test = "printf";
    char c = '"';
    unsigned long long test_len = 10;
    int j;
    for(j = 0; j < '\n'; j++);
    printf("%d,",j);

    // cout << c << endl;

    // cout << SDBMHash(test)%test_len << endl; 


}