int main()
{
  int a;
  int b;
  int c;
  c = 1;
  a = 10;
  b = &a;
  a = test(b,c); /*Function call */
  printf("%d\n",a);
}

int test(int d,int e) {  /*Function definition */
  int a;
  int b;
  a = 0 * (1 ||  e);
  if (a > 0) {
    return d;
  }
  else {
    return 1;
  }
}

