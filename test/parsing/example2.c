/* We don't (yet) support pre-processor directives. */

int main ()
{
  x = 9;
  y = 2.5; 
  y = y / x;
  z = f() + x[2][3];
  z[1][x]; /* this statement has no effect, but is valid PidginC statement */
  w = 2 + foo(x,10);
  printf("%d %d\n", x, w);
}
