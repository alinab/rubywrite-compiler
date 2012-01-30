int main()
{
  int a,b,*c
  a = 3;
  b = 5;
  c = &a;
  print("c -> a\n");
  while( a != 15) {
    print("a,b,c %d %d %d\n",a,b,c);
    b = b + a;
    if(b < 35) {
      continue ;
    }
    else {
      printf("Now b is greater than 35\n");
      break;
    }
    a = a + 1;
  }
}
