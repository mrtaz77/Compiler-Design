int factorial(int n){
	if (n == 1) return 1;
	else return factorial(n-1) * n;
}

int main() {
	int a;
	a = factorial(4);
	println(a);
	return 0;
}