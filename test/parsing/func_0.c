/*Example  taken from Wikipedia */
int fac(int n) /*Function declaration */

int main()
{
  int a
  a = 20;
  fac(a); /*Function call */
}

int fac(int n) {  /*Function definition */
  if (n == 0){
    return 1;
    }
  else
  {
    return (n * fac(n - 1));
  }
}
