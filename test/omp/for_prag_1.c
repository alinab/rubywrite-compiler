# include <stdio.h>
# include <omp.h>
# include <pthread.h>
# include <stdlib.h>
# define NUM_THREADS 5
int main()
{
  double a[20];
  double b[20];
  int n;
  int lp;
  n = 20;
  for (lp = 1; lp < n; lp = lp +1) 
    {
    a[lp] = 10 * lp * (lp+1) /2.5;
    }
  #pragma omp for schedule(static,1)
  {
    for (lp = 0; lp < n; lp = lp+1)
      {
      b[lp] = (a[lp] + a[(lp-1)] )/2.0;
      printf("\nThe value of Array b in the for pragma(static) lps %f\n",b[lp]); 
      }
  }
}



