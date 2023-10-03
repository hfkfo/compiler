#include<stdio.h>
int main()
{
	int a,b[2];
	a = 1;
	b[0] = 2;
	b[0]++;
	printf("%d",a+b[0]);//1+2
	return 0;
}
