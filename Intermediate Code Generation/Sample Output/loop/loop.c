int main(){
    int a,b,c,i;
    b=0;
	c=1;
    for(i=0;i<4;i++){
        a=3;
        while(a--){
            b++;
        }
    }
    println(a);// -1
    println(b);// 12
    println(c);// 1
	return 0;
}