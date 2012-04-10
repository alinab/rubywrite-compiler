int main()
{
  int a;
  char b;
  a = 3;
  b = "e"; /*cha const written as " "*/
  printf("a r %d\n",a);
  printf("b %c ASCII %d\n",b,b);
  while(a != 20) {
    b = b + 1;
    a = a + 1;
    while(b != "r"){
      a = a - 2;
      }
  }
  printf("b %c ASCII %d\n",b,b);
  printf("a %d\n",a);
}
  
