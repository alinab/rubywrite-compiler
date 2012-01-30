int main()
{
  int a,b,c
  a = 2;
  b = 3;
  c = 5;
  while (a <= 20) {
    printf("Now the values of a,b,c are %d,%d,%d\n",a,b,c);
    b = b + 2 * c;
    if (b > 50) {
      printf("Now break statement comes next\n");
      break ;
    }
    else /*dangling else */

    a = a + 1;
  }
}
