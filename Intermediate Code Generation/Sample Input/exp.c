int main(){
    int a,b,c[3];
    a=1*(2+3)%3;
    b= 1<5;
    c[0]=2;
    if(a && b)
        c[0]++;
    else
        c[1]=c[0];
    println(a); //a=2
    println(b); //b=1
	return 0;
}