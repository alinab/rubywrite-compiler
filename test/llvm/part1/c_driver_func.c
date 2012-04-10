#include<stdio.h>
#include<stdlib.h>

extern double *matvec(double **A, double *B, double *C, int n);
int main(int argc,char **argv)
{
  double A[10][10];
  double B[10];
  double C[10];
  int i,j,n;
  double **a;
  double *b,*c;
  **a = A[0][0];
  *b = B[0];
  *c = C[0];
   
  n = 10;
  for (i=0;i<10;i++)
    for (j=0; j< 10 ;j++)
      A[i][j] = 10.0 + i + j; //matrix

  for (i=0;i<10;i++)
    B[i] = 20.0 +i; //vector

  c  = matvec(a,b,c, n);
  
  return 0;
}
   
  
