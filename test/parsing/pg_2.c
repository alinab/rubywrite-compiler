
int main()
{

  int c;
  int d;
  int *b;
  b = a + 81;
  printf("a,b %d %d\n",a,b);
  foo();
  bar();
  swapNum(&a,&b);
  printf("a b %d,%d \n",a,b);
  c = 12;
  d = &c;
  e = last(a,b,d);
  printf("e %d\n",e);
}


int foo() {
  int a ;
  int b ;
  a = 3 ;
  b = 4 ;
}
int bar() {
  int w;
  int x ;
  int e[5][5];
  int y;
  w = 0;
  x = 1;
  y = w + x +e[2][3];
  return y;
}

void swapNum(int i, int j){
  int temp; 
  temp = *i;
  *i =  *j;
  *j = temp;
}

int last(int p ,int q, int *r)
{
  int n;
    int i;
    for(n = 0; n < 10 ;n = n + 1) {
      i = i + p + q+r;
      printf("%d\n",i);
    }
    return 0;
}


