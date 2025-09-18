import os, strutils, math, algorithm

proc lcgNext(seed: var uint32): uint32 =
    seed = seed * 1664525'u32 + 1013904223'u32
    return seed

proc sievePrimes(N: uint32) =
    if N < 2:
        echo 0
        return
    
    var comp = newSeq[bool](N + 1)
    comp[0] = true
    comp[1] = true
    
    let lim = uint32(sqrt(float64(N)))
    for p in 2'u32..lim:
        if not comp[p]:
            var m = p * p
            while m <= N:
                comp[m] = true
                m += p
    
    var cnt = 0'u32
    for i in 2'u32..N:
        if not comp[i]:
            inc cnt
    echo cnt

proc sortInts(N: uint32) =
    var s = 123456789'u32
    var a = newSeq[uint32](N)
    
    for i in 0'u32..<N:
        s = lcgNext(s)
        a[i] = s
    
    a.sort()
    
    let xorv = a[0] xor a[N div 2] xor a[N - 1]
    var total = 0'u64
    for v in a:
        total += uint64(v)
    echo xorv, " ", total

proc matmul(n: uint32) =
    let N = n
    var s = 123456789'u32
    let inv = 1.0 / 4294967296.0
    
    var A = newSeq[float64](N * N)
    var B = newSeq[float64](N * N)
    var C = newSeq[float64](N * N)
    
    for i in 0'u32..<(N * N):
        s = lcgNext(s)
        A[i] = float64(s) * inv
    for i in 0'u32..<(N * N):
        s = lcgNext(s)
        B[i] = float64(s) * inv
    
    for i in 0'u32..<N:
        let row = i * N
        for k in 0'u32..<N:
            let aik = A[row + k]
            let col = k * N
            for j in 0'u32..<N:
                C[row + j] += aik * B[col + j]
    
    var sm = 0.0
    for v in C:
        sm += v
    
    let bits = cast[uint64](sm)
    echo bits.toHex(16).toLowerAscii()

proc kmp(N, M: uint32) =
    var s = 123456789'u32
    var T = newSeq[uint8](N)
    var P = newSeq[uint8](M)
    
    for i in 0'u32..<N:
        s = lcgNext(s)
        T[i] = uint8(97 + (s mod 26))
    for i in 0'u32..<M:
        s = lcgNext(s)
        P[i] = uint8(97 + (s mod 26))
    
    var lps = newSeq[uint32](M)
    var length = 0'u32
    var i = 1'u32
    while i < M:
        if P[i] == P[length]:
            inc length
            lps[i] = length
            inc i
        elif length != 0:
            length = lps[length - 1]
        else:
            lps[i] = 0
            inc i
    
    var cnt = 0'u32
    i = 0
    var j = 0'u32
    while i < N:
        if T[i] == P[j]:
            inc i
            inc j
            if j == M:
                inc cnt
                j = lps[j - 1]
        elif j != 0:
            j = lps[j - 1]
        else:
            inc i
    echo cnt

proc main() =
    let args = commandLineParams()
    if args.len < 2:
        stderr.writeLine("usage: multi <task> <args...>")
        quit(1)
    
    let task = args[0]
    
    case task:
    of "sieve_primes":
        let N = parseUInt(args[1])
        sievePrimes(uint32(N))
    of "sort_ints":
        let N = parseUInt(args[1])
        sortInts(uint32(N))
    of "matmul_f64":
        let n = parseUInt(args[1])
        matmul(uint32(n))
    of "string_kmp":
        if args.len < 3:
            stderr.writeLine("need N M")
            quit(1)
        let N = parseUInt(args[1])
        let M = parseUInt(args[2])
        kmp(uint32(N), uint32(M))
    else:
        stderr.writeLine("unknown task: " & task)
        quit(1)

when isMainModule:
    main()