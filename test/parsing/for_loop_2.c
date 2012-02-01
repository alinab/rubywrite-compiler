int main()
{
  int a;
  double b;
  char c;
  int d;
  a =  2;
  c = "1"; /*Char const */
  for (b = 2.0; b < 100.0 ; b = b + 2.0) {
    printf("a = %d\n",a);
    a = a * 2;
    if (a > 1000) {
      printf("a = %d \n",a);
      break;
    }
    else {
      d = c / 2;
      if (d > 0){
	printf("for loop odd%c \n",c);
      }
      else {
	printf("for loop even %c \n",c);
      }
      c = c + 1;
      b = b + 4.0;
      continue;
    }
  }
  b = b + 2.0;/*This statement is effectively never executed.So b increments by 4 instead of 2*/
return 0;
}
