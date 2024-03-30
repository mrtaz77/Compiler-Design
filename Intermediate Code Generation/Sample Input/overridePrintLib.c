int a;

void print_newline(int n) {
	int i;
	i = n + 1;
	println(i);
}

void print_output(int n) {
	a = n;
	println(a);
}

int var(){
	a = 1;
	a = a + 1;
	return a;
}

int main(){
	int i;
	i = 10;
	print_newline(i);// 11
	i = -31;
	print_output(i);// -31
	println(a); // -31
	return 0;
}