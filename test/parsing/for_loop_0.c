int main()
{
    double a;
    int b,i;
    a = 1;
    b = 10;
    for (i = 0; i < b; i = i + 1) {
      printf("a %f\n",a);
      a = a * (1 + a /2.0 + a /3.0 );
    }
    return 0;
}

