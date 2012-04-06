double *matvec (double **A, double *B, double *C, int n)
{
  int	i, j;
  for (i = 0; i < n; i++) {
    C[i]   = 0.0;
    for (j = 0; j < n; j++) {
      C[i] = C[i] + A[i][j]*B[j];
    }
    return C;
    }	
}
