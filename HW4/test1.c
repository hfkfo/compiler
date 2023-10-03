void main()
{
	int a;
	int b;
	a = 1;
	b = a + 2;
	if(a == 1)
	{
		printf("%d\n", b);
		if(b < 3)
		{
			printf("%d\n", b);
		}
		else if(b == 3)
		{
			printf("Hello World\n");
		}
		else
		{
			printf("%d\n",a);
		}
	}
	else
	{
		printf("Error\n");
	}
	return 0;
	
}
