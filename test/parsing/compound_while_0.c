int main()
{
  int a,b;
  a = "s"; /* all char constants are written in " "*/
  b = 1;
  while(b < 10) {
    a = a + "a";
    b = b + 1;
    if(b > 5){
     a = a + 3 * 8;
     }
  }
  a = a + "d";
  printf("a is %d\n",a);
}
