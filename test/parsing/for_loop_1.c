int main()
{
  int a
  double b
  char c
  a =  2;
  c = "1"; /*const char written with " "*/
  for (b = 2.0; b < 20.0 ; b = b + 2.0) {
    printf("a = %d\n",a);
    a = a * 5;
    if (a > 100) {

      printf("a = %d\n",a);
      return "SUCCESS";
    }
    else {
      printf("for loop ");
    }
    b = b + 2.0;
  }
}
