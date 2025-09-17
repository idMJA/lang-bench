#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>

// LCG
static inline uint32_t lcg_next(uint32_t* s){ *s = (1664525u * (*s) + 1013904223u); return *s; }

// sieve_primes N
static void task_sieve(uint64_t N){
    if (N < 2){ printf("0\n"); return; }
    uint8_t* comp = (uint8_t*)calloc(N+1, 1);
    if(!comp){ fprintf(stderr,"alloc fail\n"); exit(1); }
    comp[0]=1; comp[1]=1;
    uint64_t lim = (uint64_t)floor(sqrt((double)N));
    for(uint64_t p=2;p<=lim;p++){
        if(!comp[p]){
            uint64_t start = p*p;
            for(uint64_t m=start;m<=N;m+=p) comp[m]=1;
        }
    }
    uint64_t cnt=0;
    for(uint64_t i=2;i<=N;i++) cnt += (comp[i]==0);
    printf("%llu\n",(unsigned long long)cnt);
    free(comp);
}

// sort_ints N => xor sum_mod
static int cmp_u32(const void* a, const void* b){
    uint32_t aa=*(const uint32_t*)a, bb=*(const uint32_t*)b;
    return (aa>bb) - (aa<bb);
}
static void task_sort(uint64_t N){
    uint32_t* arr = (uint32_t*)malloc(sizeof(uint32_t)*N);
    if(!arr){ fprintf(stderr,"alloc fail\n"); exit(1); }
    uint32_t s=123456789u;
    for(uint64_t i=0;i<N;i++) arr[i]=lcg_next(&s);
    qsort(arr, (size_t)N, sizeof(uint32_t), cmp_u32);
    uint64_t xorv = arr[0] ^ arr[N/2] ^ arr[N-1];
    __uint128_t sum=0;
    for(uint64_t i=0;i<N;i++) sum += arr[i];
    uint64_t sum_mod = (uint64_t)sum;
    printf("%llu %llu\n",(unsigned long long)xorv,(unsigned long long)sum_mod);
    free(arr);
}

// matmul_f64 n => hex64 of bit pattern of sum(C)
static void task_matmul(uint64_t n){
    uint64_t N=n;
    double* A = (double*)malloc(sizeof(double)*N*N);
    double* B = (double*)malloc(sizeof(double)*N*N);
    double* C = (double*)calloc(N*N, sizeof(double));
    if(!A||!B||!C){ fprintf(stderr,"alloc fail\n"); exit(1); }
    uint32_t s=123456789u;
    const double inv = 1.0/4294967296.0;
    for(uint64_t i=0;i<N*N;i++) A[i] = (double)lcg_next(&s)*inv;
    for(uint64_t i=0;i<N*N;i++) B[i] = (double)lcg_next(&s)*inv;
    for(uint64_t i=0;i<N;i++){
        for(uint64_t k=0;k<N;k++){
            double aik = A[i*N+k];
            for(uint64_t j=0;j<N;j++){
                C[i*N+j] += aik * B[k*N+j];
            }
        }
    }
    double sum=0.0;
    for(uint64_t i=0;i<N*N;i++) sum += C[i];
    union { double d; uint64_t u; } u; u.d = sum;
    printf("%016llx\n",(unsigned long long)u.u);
    free(A); free(B); free(C);
}

// string_kmp N M => count
static void kmp_build(const char* p, int m, int* lps){
    int len=0; lps[0]=0; int i=1;
    while(i<m){
        if(p[i]==p[len]){ len++; lps[i]=len; i++; }
        else if(len!=0){ len = lps[len-1]; }
        else { lps[i]=0; i++; }
    }
}
static void task_kmp(uint64_t N, uint64_t M){
    char* T=(char*)malloc(N);
    char* P=(char*)malloc(M);
    if(!T||!P){ fprintf(stderr,"alloc fail\n"); exit(1); }
    uint32_t s=123456789u;
    for(uint64_t i=0;i<N;i++){ uint32_t v=lcg_next(&s); T[i] = (char)('a' + (v%26)); }
    for(uint64_t i=0;i<M;i++){ uint32_t v=lcg_next(&s); P[i] = (char)('a' + (v%26)); }
    int m=(int)M;
    int* lps=(int*)malloc(sizeof(int)*m);
    if(!lps){ fprintf(stderr,"alloc fail\n"); exit(1); }
    kmp_build(P,m,lps);
    uint64_t cnt=0;
    int i=0,j=0, n=(int)N;
    while(i<n){
        if(T[i]==P[j]){ i++; j++; if(j==m){ cnt++; j=lps[j-1]; } }
        else if(j!=0){ j=lps[j-1]; }
        else i++;
    }
    printf("%llu\n",(unsigned long long)cnt);
    free(T); free(P); free(lps);
}

int main(int argc, char** argv){
    if(argc<3){
        fprintf(stderr,"usage: %s <task> <args...>\n", argv[0]);
        return 1;
    }
    const char* task = argv[1];
    if(strcmp(task,"sieve_primes")==0){
        uint64_t N = strtoull(argv[2],NULL,10);
        task_sieve(N);
    } else if(strcmp(task,"sort_ints")==0){
        uint64_t N = strtoull(argv[2],NULL,10);
        task_sort(N);
    } else if(strcmp(task,"matmul_f64")==0){
        uint64_t n = strtoull(argv[2],NULL,10);
        task_matmul(n);
    } else if(strcmp(task,"string_kmp")==0){
        if(argc<4){ fprintf(stderr,"need N M\n"); return 1; }
        uint64_t N = strtoull(argv[2],NULL,10);
        uint64_t M = strtoull(argv[3],NULL,10);
        task_kmp(N,M);
    } else {
        fprintf(stderr,"unknown task: %s\n", task);
        return 1;
    }
    return 0;
}