void foo(char a)
int main()
{
  int i
  char b
  char a[20] 
  a[20] = "This is a string";
  b = a;
  i = 0;
  foo(b);
  while(a[i] != NULL){
    printf("%c",a[i]);
    i = i + 1;
  }
  printf("\n");
  return 0;
}

void foo(char c)
{
  int i
  i = 0;
  while(c[i] != NULL){
    c[i] = c[i] + 1;
    i = i + 1;
  }
}
