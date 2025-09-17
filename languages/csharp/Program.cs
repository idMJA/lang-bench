using System;
using System.Linq;

static class LCG {
    public static uint Next(ref uint s){ s = 1664525u*s + 1013904223u; return s; }
}

class Program {
    static void Sieve(int N){
        if(N<2){ Console.WriteLine(0); return; }
        var comp = new bool[N+1]; comp[0]=true; comp[1]=true;
        int lim = (int)Math.Floor(Math.Sqrt(N));
        for(int p=2;p<=lim;p++){
            if(!comp[p]){
                long st = 1L*p*p;
                for(long m=st;m<=N;m+=p) comp[(int)m]=true;
            }
        }
        int cnt=0; for(int i=2;i<=N;i++) if(!comp[i]) cnt++;
        Console.WriteLine(cnt);
    }

    static void SortInts(int N){
        var a = new uint[N];
        uint s = 123456789;
        for(int i=0;i<N;i++) a[i]=LCG.Next(ref s);
        Array.Sort(a);
        ulong xorv = a[0] ^ a[N/2] ^ a[N-1];
        ulong sum = 0; foreach(var v in a) sum += v;
        Console.WriteLine($"{xorv} {sum}");
    }

    static void Matmul(int n){
        int N=n;
        var A=new double[N*N];
        var B=new double[N*N];
        var C=new double[N*N];
        uint s=123456789;
        double inv=1.0/4294967296.0;
        for(int i=0;i<N*N;i++) A[i] = LCG.Next(ref s)*inv;
        for(int i=0;i<N*N;i++) B[i] = LCG.Next(ref s)*inv;
        for(int i=0;i<N;i++){
            int row=i*N;
            for(int k=0;k<N;k++){
                double aik=A[row+k];
                int col=k*N;
                for(int j=0;j<N;j++) C[row+j]+=aik*B[col+j];
            }
        }
        double sum=0; for(int i=0;i<N*N;i++) sum+=C[i];
        ulong bits = (ulong)BitConverter.DoubleToInt64Bits(sum);
        Console.WriteLine($"{bits:x16}");
    }

    static void KMP(int N, int M){
        var T=new byte[N]; var P=new byte[M];
        uint s=123456789;
        for(int i=0;i<N;i++){ T[i]=(byte)('a'+(LCG.Next(ref s)%26)); }
        for(int i=0;i<M;i++){ P[i]=(byte)('a'+(LCG.Next(ref s)%26)); }
        var lps=new int[M]; int len=0;
        for(int i=1;i<M;){
            if(P[i]==P[len]){ len++; lps[i]=len; i++; }
            else if(len!=0){ len=lps[len-1]; }
            else { lps[i]=0; i++; }
        }
        ulong cnt=0; int ii=0,j=0;
        while(ii<N){
            if(T[ii]==P[j]){ ii++; j++; if(j==M){ cnt++; j=lps[j-1]; } }
            else if(j!=0){ j=lps[j-1]; }
            else ii++;
        }
        Console.WriteLine(cnt);
    }

    static int Main(string[] args){
        if(args.Length<2){ Console.Error.WriteLine("usage: Multi <task> <args...>"); return 1; }
        switch(args[0]){
            case "sieve_primes": Sieve(int.Parse(args[1])); break;
            case "sort_ints": SortInts(int.Parse(args[1])); break;
            case "matmul_f64": Matmul(int.Parse(args[1])); break;
            case "string_kmp":
                if(args.Length<3){ Console.Error.WriteLine("need N M"); return 1; }
                KMP(int.Parse(args[1]), int.Parse(args[2])); break;
            default: Console.Error.WriteLine("unknown task"); return 1;
        }
        return 0;
    }
}