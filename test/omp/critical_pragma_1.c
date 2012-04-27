# include <stdio.h>
# include <omp.h>
# include <pthread.h>
# include <stdlib.h>
# define NUM_THREADS 5
int main ()
{
int a;
int b;
int c;
a = 3 * 2;
b = 10 * a + a;
c = b+a;
#pragma omp critical
{
printf("Here a = %d\n",a);
printf("Here b = %d\n",b);
printf("Here c = %d\n",c);
printf("Here a+b+c = %d \n",a+b+c);
printf("Hello from thread %d, nthreads %d\n", omp_get_thread_num(), omp_get_num_threads());
}
printf("Exit \n");
}


