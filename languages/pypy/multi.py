#!/usr/bin/env pypy3
import sys, math, array, struct

def lcg_next(s: int) -> int:
    return (1664525 * s + 1013904223) & 0xFFFFFFFF

def sieve_primes(N: int):
    if N < 2:
        print(0); return
    comp = bytearray(N+1)
    comp[0]=1; comp[1]=1
    lim = int(math.isqrt(N))
    for p in range(2, lim+1):
        if comp[p]==0:
            start = p*p
            comp[start:N+1:p] = b'\x01'*(((N-start)//p)+1)
    print((N-1) - sum(comp[2:]))

def sort_ints(N: int):
    s = 123456789
    a = [0]*N
    for i in range(N):
        s = lcg_next(s); a[i] = s
    a.sort()
    xorv = (a[0] ^ a[N//2] ^ a[-1]) & 0xFFFFFFFF
    total = 0
    for v in a:
        total = (total + (v & 0xFFFFFFFF)) & 0xFFFFFFFFFFFFFFFF
    print(f"{xorv} {total}")

def matmul(n: int):
    N=n
    s=123456789
    inv = 1.0/4294967296.0
    A=[0.0]*(N*N); B=[0.0]*(N*N); C=[0.0]*(N*N)
    for i in range(N*N):
        s = lcg_next(s); A[i] = (s)*inv
    for i in range(N*N):
        s = lcg_next(s); B[i] = (s)*inv
    for i in range(N):
        row=i*N
        for k in range(N):
            aik=A[row+k]
            col=k*N
            for j in range(N):
                C[row+j] += aik * B[col+j]
    sm = 0.0
    for v in C: sm += v
    bits = struct.unpack('>Q', struct.pack('>d', sm))[0]
    print(f"{bits:016x}")

def kmp(N: int, M: int):
    s = 123456789
    T = bytearray(N); P = bytearray(M)
    for i in range(N):
        s = lcg_next(s); T[i] = 97 + (s % 26)
    for i in range(M):
        s = lcg_next(s); P[i] = 97 + (s % 26)
    lps = [0]*M
    length = 0; i = 1
    while i < M:
        if P[i]==P[length]:
            length += 1; lps[i] = length; i += 1
        elif length != 0:
            length = lps[length-1]
        else:
            lps[i] = 0; i += 1
    cnt = 0
    i = j = 0
    while i < N:
        if T[i]==P[j]:
            i += 1; j += 1
            if j == M:
                cnt += 1; j = lps[j-1]
        elif j != 0:
            j = lps[j-1]
        else:
            i += 1
    print(cnt)

def main():
    if len(sys.argv) < 3:
        print(f"usage: {sys.argv[0]} <task> <args...>", file=sys.stderr)
        sys.exit(1)
    task = sys.argv[1]
    if task == "sieve_primes":
        sieve_primes(int(sys.argv[2]))
    elif task == "sort_ints":
        sort_ints(int(sys.argv[2]))
    elif task == "matmul_f64":
        matmul(int(sys.argv[2]))
    elif task == "string_kmp":
        if len(sys.argv) < 4:
            print("need N M", file=sys.stderr); sys.exit(1)
        kmp(int(sys.argv[2]), int(sys.argv[3]))
    else:
        print("unknown task", file=sys.stderr); sys.exit(1)

if __name__ == "__main__":
    main()