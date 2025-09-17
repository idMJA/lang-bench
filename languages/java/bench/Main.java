package bench;
import java.util.*;

public class Main {
    static int atoi(String s){ return Integer.parseInt(s); }
    static long atoll(String s){ return Long.parseLong(s); }

    static int sievePrimes(int N){
        if(N<2) return 0;
        boolean[] comp = new boolean[N+1];
        comp[0]=comp[1]=true;
        int lim = (int)Math.floor(Math.sqrt(N));
        for(int p=2;p<=lim;p++){
            if(!comp[p]){
                long st = 1L*p*p;
                for(long m=st;m<=N;m+=p) comp[(int)m]=true;
            }
        }
        int cnt=0; for(int i=2;i<=N;i++) if(!comp[i]) cnt++;
        return cnt;
    }

    static long[] sortInts(int N){
        int[] a = new int[N];
        int s = 123456789;
        for(int i=0;i<N;i++){ s = 1664525*s + 1013904223; a[i]=s; }
        Arrays.sort(a);
        long xorv = (a[0]&0xffffffffL) ^ (a[N/2]&0xffffffffL) ^ (a[N-1]&0xffffffffL);
        long sum = 0L; for(int v: a) sum += (v & 0xffffffffL);
        return new long[]{xorv, sum};
    }

    static String matmul(int n){
        int N=n;
        double[] A=new double[N*N], B=new double[N*N], C=new double[N*N];
        int s=123456789;
        double inv=1.0/4294967296.0;
        for(int i=0;i<N*N;i++){ s=1664525*s+1013904223; A[i]=(s & 0xffffffffL)*inv; }
        for(int i=0;i<N*N;i++){ s=1664525*s+1013904223; B[i]=(s & 0xffffffffL)*inv; }
        for(int i=0;i<N;i++){
            int row=i*N;
            for(int k=0;k<N;k++){
                double aik=A[row+k];
                int col=k*N;
                for(int j=0;j<N;j++){
                    C[row+j] += aik * B[col+j];
                }
            }
        }
        double sum=0; for(int i=0;i<N*N;i++) sum += C[i];
        long bits = Double.doubleToRawLongBits(sum);
        return String.format("%016x", bits);
    }

    static int kmp(int N, int M){
        byte[] T=new byte[N], P=new byte[M];
        int s=123456789;
        for(int i=0;i<N;i++){ s=1664525*s+1013904223; T[i]=(byte)('a'+((s>>>0)&25)); }
        for(int i=0;i<M;i++){ s=1664525*s+1013904223; P[i]=(byte)('a'+((s>>>0)&25)); }
        int[] lps=new int[M];
        for(int i=1,len=0;i<M;){
            if(P[i]==P[len]) { lps[i++]=++len; }
            else if(len!=0){ len=lps[len-1]; }
            else { lps[i++]=0; }
        }
        int cnt=0;
        for(int i=0,j=0;i<N;){
            if(T[i]==P[j]){ i++; j++; if(j==M){ cnt++; j=lps[j-1]; } }
            else if(j!=0){ j=lps[j-1]; }
            else i++;
        }
        return cnt;
    }

    public static void main(String[] args){
        if(args.length<2){
            System.err.println("usage: Main <task> <args...>");
            System.exit(1);
        }
        String task=args[0];
        switch(task){
            case "sieve_primes": {
                int N=atoi(args[1]);
                System.out.println(sievePrimes(N));
                break;
            }
            case "sort_ints": {
                int N=atoi(args[1]);
                long[] r=sortInts(N);
                System.out.println(r[0]+" "+r[1]);
                break;
            }
            case "matmul_f64": {
                int n=atoi(args[1]);
                System.out.println(matmul(n));
                break;
            }
            case "string_kmp": {
                if(args.length<3){ System.err.println("need N M"); System.exit(1); }
                int N=atoi(args[1]), M=atoi(args[2]);
                System.out.println(kmp(N,M));
                break;
            }
            default:
                System.err.println("unknown task: "+task);
                System.exit(1);
        }
    }
}