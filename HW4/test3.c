void main()
{
	int a;
	int b;
	int c;
	int d;
	a = 10;
	b = 1;
	c = 2;
	d = 0;
	while(a >= 0)
	{
		if(a >= 5)
		{
			a = a - b;
			d = d + 1;
		}
		else
		{
			a = a - c;
			d = d + 1;
		}
	}	 
	printf("%d\n%d\n",a,d);
	return 0;
}
