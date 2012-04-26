# include < stdio.h >
# include < omp.h >
# include < pthread.h >
# include < stdlib.h >
# define NUM_THREADS 5
int main ()
{
int a;
int b;
int c;
a = 3;
b = 10;
c = b+a;
#pragma omp parallel
{
printf("Here a = %d\n",a);
}
b = a * 10;
a = 2 * b;
#pragma omp parallel
{
printf("Here a = %d\n",a);
printf("Hello from thread %d, nthreads %d\n", omp_get_thread_num(), omp_get_num_threads());
}
printf("Exit \n");
}


