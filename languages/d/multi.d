import std.stdio;
import std.conv;
import std.algorithm;
import std.math;
import std.array;

uint lcgNext(ref uint s) {
    s = (1664525u * s + 1013904223u);
    return s;
}

void sievePrimes(ulong N) {
    if (N < 2) {
        writeln(0);
        return;
    }
    
    bool[] comp = new bool[N + 1];
    comp[0] = true;
    comp[1] = true;
    
    ulong lim = cast(ulong)sqrt(cast(double)N);
    for (ulong p = 2; p <= lim; p++) {
        if (!comp[p]) {
            for (ulong m = p * p; m <= N; m += p) {
                comp[m] = true;
            }
        }
    }
    
    ulong count = 0;
    for (ulong i = 2; i <= N; i++) {
        if (!comp[i]) count++;
    }
    writeln(count);
}

void sortInts(ulong N) {
    uint[] arr = new uint[N];
    uint s = 123456789u;
    
    for (ulong i = 0; i < N; i++) {
        arr[i] = lcgNext(s);
    }
    
    arr.sort();
    
    ulong xorv = (cast(ulong)arr[0]) ^ (cast(ulong)arr[N/2]) ^ (cast(ulong)arr[N-1]);
    ulong total = 0;
    foreach (v; arr) {
        total += cast(ulong)v;
    }
    
    writefln("%d %d", xorv & 0xFFFFFFFFUL, total);
}

void matmul(int n) {
    int N = n;
    double[] A = new double[N * N];
    double[] B = new double[N * N];
    double[] C = new double[N * N];
    uint s = 123456789u;
    double inv = 1.0 / 4294967296.0;
    
    // Fill matrices
    for (int i = 0; i < N * N; i++) {
        A[i] = lcgNext(s) * inv;
    }
    for (int i = 0; i < N * N; i++) {
        B[i] = lcgNext(s) * inv;
    }
    
    // Matrix multiplication
    for (int i = 0; i < N; i++) {
        int row = i * N;
        for (int k = 0; k < N; k++) {
            double aik = A[row + k];
            int col = k * N;
            for (int j = 0; j < N; j++) {
                C[row + j] += aik * B[col + j];
            }
        }
    }
    
    // Sum all elements
    double sum = 0.0;
    foreach (v; C) {
        sum += v;
    }
    
    // Convert to hex
    union DoubleBytes {
        double d;
        ulong bits;
    }
    DoubleBytes db;
    db.d = sum;
    writefln("%016x", db.bits);
}

void kmpSearch(ulong N, ulong M) {
    ubyte[] T = new ubyte[N];
    ubyte[] P = new ubyte[M];
    uint s = 123456789u;
    
    // Generate text and pattern
    for (ulong i = 0; i < N; i++) {
        T[i] = cast(ubyte)('a' + (lcgNext(s) % 26));
    }
    for (ulong i = 0; i < M; i++) {
        P[i] = cast(ubyte)('a' + (lcgNext(s) % 26));
    }
    
    // Build LPS array
    int[] lps = new int[M];
    int len = 0;
    int i = 1;
    
    while (i < M) {
        if (P[i] == P[len]) {
            len++;
            lps[i] = len;
            i++;
        } else if (len != 0) {
            len = lps[len - 1];
        } else {
            lps[i] = 0;
            i++;
        }
    }
    
    // KMP search
    ulong count = 0;
    i = 0;
    int j = 0;
    
    while (i < N) {
        if (T[i] == P[j]) {
            i++;
            j++;
            if (j == M) {
                count++;
                j = lps[j - 1];
            }
        } else if (j != 0) {
            j = lps[j - 1];
        } else {
            i++;
        }
    }
    
    writeln(count);
}

void main(string[] args) {
    if (args.length < 3) {
        stderr.writeln("usage: ", args[0], " <task> <args...>");
        return;
    }
    
    string task = args[1];
    
    switch (task) {
        case "sieve_primes":
            ulong N = to!ulong(args[2]);
            sievePrimes(N);
            break;
        case "sort_ints":
            ulong N = to!ulong(args[2]);
            sortInts(N);
            break;
        case "matmul_f64":
            int n = to!int(args[2]);
            matmul(n);
            break;
        case "string_kmp":
            if (args.length < 4) {
                stderr.writeln("need N M");
                return;
            }
            ulong N = to!ulong(args[2]);
            ulong M = to!ulong(args[3]);
            kmpSearch(N, M);
            break;
        default:
            stderr.writeln("unknown task: ", task);
            return;
    }
}