import std.stdio;
import std.conv;
import std.algorithm;
import std.array;
import std.math;
import std.bitmanip;

uint lcgNext(ref uint seed) {
    seed = seed * 1664525u + 1013904223u;
    return seed;
}

void sievePrimes(uint N) {
    if (N < 2) {
        writeln(0);
        return;
    }
    
    auto comp = new bool[N + 1];
    comp[0] = comp[1] = true;
    
    uint lim = cast(uint)sqrt(cast(real)N);
    for (uint p = 2; p <= lim; p++) {
        if (!comp[p]) {
            for (uint m = p * p; m <= N; m += p) {
                comp[m] = true;
            }
        }
    }
    
    uint cnt = 0;
    for (uint i = 2; i <= N; i++) {
        if (!comp[i]) cnt++;
    }
    writeln(cnt);
}

void sortInts(uint N) {
    uint s = 123456789;
    auto a = new uint[N];
    
    for (uint i = 0; i < N; i++) {
        s = lcgNext(s);
        a[i] = s;
    }
    
    a.sort();
    
    uint xorv = a[0] ^ a[N / 2] ^ a[N - 1];
    ulong total = 0;
    foreach (v; a) {
        total += v;
    }
    writefln("%u %u", xorv, total);
}

void matmul(uint n) {
    uint N = n;
    uint s = 123456789;
    double inv = 1.0 / 4294967296.0;
    
    auto A = new double[N * N];
    auto B = new double[N * N];
    auto C = new double[N * N];
    
    for (uint i = 0; i < N * N; i++) {
        s = lcgNext(s);
        A[i] = cast(double)s * inv;
    }
    for (uint i = 0; i < N * N; i++) {
        s = lcgNext(s);
        B[i] = cast(double)s * inv;
    }
    
    for (uint i = 0; i < N; i++) {
        uint row = i * N;
        for (uint k = 0; k < N; k++) {
            double aik = A[row + k];
            uint col = k * N;
            for (uint j = 0; j < N; j++) {
                C[row + j] += aik * B[col + j];
            }
        }
    }
    
    double sm = 0.0;
    foreach (v; C) sm += v;
    
    ulong bits = *(cast(ulong*)&sm);
    writefln("%016x", bits);
}

void kmp(uint N, uint M) {
    uint s = 123456789;
    auto T = new ubyte[N];
    auto P = new ubyte[M];
    
    for (uint i = 0; i < N; i++) {
        s = lcgNext(s);
        T[i] = cast(ubyte)(97 + (s % 26));
    }
    for (uint i = 0; i < M; i++) {
        s = lcgNext(s);
        P[i] = cast(ubyte)(97 + (s % 26));
    }
    
    auto lps = new uint[M];
    uint length = 0;
    uint i = 1;
    while (i < M) {
        if (P[i] == P[length]) {
            length++;
            lps[i] = length;
            i++;
        } else if (length != 0) {
            length = lps[length - 1];
        } else {
            lps[i] = 0;
            i++;
        }
    }
    
    uint cnt = 0;
    i = 0;
    uint j = 0;
    while (i < N) {
        if (T[i] == P[j]) {
            i++;
            j++;
            if (j == M) {
                cnt++;
                j = lps[j - 1];
            }
        } else if (j != 0) {
            j = lps[j - 1];
        } else {
            i++;
        }
    }
    writeln(cnt);
}

void main(string[] args) {
    if (args.length < 3) {
        stderr.writeln("usage: multi <task> <args...>");
        return;
    }
    
    string task = args[1];
    
    if (task == "sieve_primes") {
        uint N = to!uint(args[2]);
        sievePrimes(N);
    } else if (task == "sort_ints") {
        uint N = to!uint(args[2]);
        sortInts(N);
    } else if (task == "matmul_f64") {
        uint n = to!uint(args[2]);
        matmul(n);
    } else if (task == "string_kmp") {
        if (args.length < 4) {
            stderr.writeln("need N M");
            return;
        }
        uint N = to!uint(args[2]);
        uint M = to!uint(args[3]);
        kmp(N, M);
    } else {
        stderr.writefln("unknown task: %s", task);
    }
}