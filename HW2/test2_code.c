#include<stdio.h>
void main()
{
	double a;
	int b;
	a = 1;
	b = 2;
	if(a == 1)
	{
		if(b == 2)
			printf("%lf\n",a);
		else
			printf("3");
	}
	else if(a == 0)
		printf("0");
	else
		printf("2");
	return 0;
}
