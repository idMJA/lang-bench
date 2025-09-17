#include <bits/stdc++.h>
using namespace std;

static inline uint32_t lcg_next(uint32_t &s){ s = 1664525u*s + 1013904223u; return s; }

void sieve(uint64_t N){
    if(N<2){ cout<<0<<"\n"; return; }
    vector<uint8_t> comp(N+1,0); comp[0]=comp[1]=1;
    uint64_t lim = sqrt((long double)N);
    for(uint64_t p=2;p<=lim;p++){
        if(!comp[p]){
            uint64_t st=p*p;
            for(uint64_t m=st;m<=N;m+=p) comp[m]=1;
        }
    }
    uint64_t cnt=0; for(uint64_t i=2;i<=N;i++) cnt += (comp[i]==0);
    cout<<cnt<<"\n";
}
void sort_ints(uint64_t N){
    vector<uint32_t> a; a.reserve(N);
    uint32_t s=123456789u; for(uint64_t i=0;i<N;i++) a.push_back(lcg_next(s));
    sort(a.begin(), a.end());
    uint64_t x = (uint64_t)a[0] ^ a[N/2] ^ a[N-1];
    unsigned __int128 sum=0; for(uint32_t v: a) sum += v;
    uint64_t sum_mod = (uint64_t)sum;
    cout<<x<<" "<<sum_mod<<"\n";
}
void matmul(uint64_t n){
    size_t N=n;
    vector<double> A(N*N), B(N*N), C(N*N,0.0);
    uint32_t s=123456789u; const double inv = 1.0/4294967296.0;
    for(size_t i=0;i<N*N;i++) A[i] = (double)lcg_next(s)*inv;
    for(size_t i=0;i<N*N;i++) B[i] = (double)lcg_next(s)*inv;
    for(size_t i=0;i<N;i++){
        for(size_t k=0;k<N;k++){
            double aik=A[i*N+k];
            for(size_t j=0;j<N;j++) C[i*N+j]+=aik*B[k*N+j];
        }
    }
    double sum=0; for(double v:C) sum+=v;
    uint64_t bits; memcpy(&bits,&sum,8);
    std::ostringstream oss; oss<<std::hex<<setw(16)<<setfill('0')<<bits;
    cout<<oss.str()<<"\n";
}
void kmp(uint64_t N, uint64_t M){
    string T, P; T.resize(N); P.resize(M);
    uint32_t s=123456789u;
    for(size_t i=0;i<N;i++){ T[i] = char('a' + (lcg_next(s)%26)); }
    for(size_t i=0;i<M;i++){ P[i] = char('a' + (lcg_next(s)%26)); }
    vector<int> lps(M); // build
    for(size_t i=1,len=0;i<M;){
        if(P[i]==P[len]) lps[i++]=++len;
        else if(len) len=lps[len-1];
        else lps[i++]=0;
    }
    uint64_t cnt=0;
    for(size_t i=0,j=0;i<N;){
        if(T[i]==P[j]){ i++; j++; if(j==M){ cnt++; j=lps[j-1]; } }
        else if(j) j=lps[j-1];
        else i++;
    }
    cout<<cnt<<"\n";
}

int main(int argc, char** argv){
    if(argc<3){ cerr<<"usage: "<<argv[0]<<" <task> <args...>\n"; return 1; }
    string task = argv[1];
    if(task=="sieve_primes"){ uint64_t N=stoull(argv[2]); sieve(N); }
    else if(task=="sort_ints"){ uint64_t N=stoull(argv[2]); sort_ints(N); }
    else if(task=="matmul_f64"){ uint64_t n=stoull(argv[2]); matmul(n); }
    else if(task=="string_kmp"){ if(argc<4){ cerr<<"need N M\n"; return 1; } kmp(stoull(argv[2]), stoull(argv[3])); }
    else { cerr<<"unknown task\n"; return 1; }
    return 0;
}