/*void foo(int *a);*/
int main()
{
  int a[10],i
  int b
  b = a;
  foo(b);
  for(i = 0;i < 10;i = i + 1){
    printf("%d %d\n",a[i],i);
  }
  return 0;
}

void foo(int c)
{
  int i
  for(i = 0;i < 10;i = i + 1){
    c[i] = i * 2 * (1 + i /2 + i / 3);
  }
}
