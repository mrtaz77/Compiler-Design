#include <iostream>
using namespace std;

static uint64_t sdbm_hash(string str) {
	uint64_t hash = 0;
	uint64_t i = 0;
	uint64_t len = str.length();

	for (i = 0; i < len; i++)
	{
		hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
	}

	return hash;
}

int main(){
    // freopen("hashText.txt", "r", stdin);

    string name;
    cin >> name ;

    cout << "foo" << endl;
    cout << sdbm_hash(name) << endl;

    for(uint64_t i = 1; i < 10 ; i++){
        cout<< i << " : " <<sdbm_hash(name) % i << endl;
    }
}