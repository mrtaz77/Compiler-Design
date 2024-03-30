int f1(int,int);
int global_array[10];

int main(){
	int a,local_array[10],b,t1,t2;
	a = 2 + 3 + 4;
	b = 2 + 3 * -5 + -9;
	global_array[f1(3,2)] = f1(a,b);
	local_array[f1(1,4)] = f1(16,global_array[5]);
	t1 = global_array[f1(global_array[5],18)];
	t2 = local_array[f1(local_array[5],2)];
	println(t1); // 13
	println(t2); // -3
	return 0;
}

int f1(int a, int b){
	return a + b;
}