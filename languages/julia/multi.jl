#!/usr/bin/env julia

function lcg_next!(s::Ref{UInt32})
    s[] = s[] * 1664525 + 1013904223
    return s[]
end

function sieve_primes(N::Int)
    if N < 2
        println(0)
        return
    end
    
    comp = fill(false, N + 1)
    comp[1] = comp[2] = true  # 0-indexed becomes 1-indexed
    
    lim = Int(floor(sqrt(N)))
    for p = 2:lim
        if !comp[p + 1]  # +1 for 1-indexed
            for m = p*p:p:N
                comp[m + 1] = true  # +1 for 1-indexed
            end
        end
    end
    
    cnt = 0
    for i = 2:N
        if !comp[i + 1]  # +1 for 1-indexed
            cnt += 1
        end
    end
    println(cnt)
end

function sort_ints(N::Int)
    s = Ref{UInt32}(123456789)
    a = Vector{UInt32}(undef, N)
    
    for i = 1:N
        a[i] = lcg_next!(s)
    end
    
    sort!(a)
    
    xorv = (a[1] ⊻ a[N÷2 + 1] ⊻ a[N]) & 0xFFFFFFFF
    total = UInt64(0)
    for v in a
        total = (total + UInt64(v)) & 0xFFFFFFFFFFFFFFFF
    end
    println("$xorv $total")
end

function matmul(n::Int)
    N = n
    s = Ref{UInt32}(123456789)
    inv = 1.0 / 4294967296.0
    
    A = Matrix{Float64}(undef, N, N)
    B = Matrix{Float64}(undef, N, N)
    
    for i = 1:N, j = 1:N
        A[i, j] = Float64(lcg_next!(s)) * inv
    end
    for i = 1:N, j = 1:N
        B[i, j] = Float64(lcg_next!(s)) * inv
    end
    
    C = A * B
    sm = sum(C)
    
    bits = reinterpret(UInt64, sm)
    println(string(bits, base=16, pad=16))
end

function kmp(N::Int, M::Int)
    s = Ref{UInt32}(123456789)
    T = Vector{UInt8}(undef, N)
    P = Vector{UInt8}(undef, M)
    
    for i = 1:N
        T[i] = 97 + (lcg_next!(s) % 26)
    end
    for i = 1:M
        P[i] = 97 + (lcg_next!(s) % 26)
    end
    
    # Build LPS array
    lps = zeros(Int, M)
    length = 0
    i = 2
    while i <= M
        if P[i] == P[length + 1]
            length += 1
            lps[i] = length
            i += 1
        elseif length != 0
            length = lps[length]
        else
            lps[i] = 0
            i += 1
        end
    end
    
    # Search
    cnt = 0
    i = 1
    j = 1
    while i <= N
        if T[i] == P[j]
            i += 1
            j += 1
            if j > M
                cnt += 1
                j = lps[j - 1] + 1
            end
        elseif j > 1
            j = lps[j - 1] + 1
        else
            i += 1
        end
    end
    println(cnt)
end

function main()
    if length(ARGS) < 2
        println(stderr, "usage: multi.jl <task> <args...>")
        exit(1)
    end
    
    task = ARGS[1]
    
    if task == "sieve_primes"
        N = parse(Int, ARGS[2])
        sieve_primes(N)
    elseif task == "sort_ints"
        N = parse(Int, ARGS[2])
        sort_ints(N)
    elseif task == "matmul_f64"
        n = parse(Int, ARGS[2])
        matmul(n)
    elseif task == "string_kmp"
        if length(ARGS) < 3
            println(stderr, "need N M")
            exit(1)
        end
        N = parse(Int, ARGS[2])
        M = parse(Int, ARGS[3])
        kmp(N, M)
    else
        println(stderr, "unknown task: $task")
        exit(1)
    end
end

main()