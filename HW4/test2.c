void main()
{
	int a;
	int b;
	int c;
	b = 0;
	c = 0;
	for(a = 0 ; a < 10 ; a = a + 1)
	{
		if(a < 5)
		{
			if(b == 0)
			{
				b = 100;
			}
			else
			{
				b = b + 1;
			}
		}
		else
		{
			c = c + 1;
		}
	}
	printf("%d\n%d\n%d\n",a,b,c);
	return 0;
}
