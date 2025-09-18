#!/usr/bin/env julia

function lcg_next!(s::Vector{UInt32})::UInt32
    s[1] = (UInt32(1664525) * s[1] + UInt32(1013904223)) & UInt32(0xFFFFFFFF)
    return s[1]
end

function sieve_primes(N::Int)
    if N < 2
        println(0)
        return
    end
    
    comp = falses(N + 1)
    comp[1] = true
    comp[2] = true  # 0-indexed becomes 1-indexed
    
    lim = isqrt(N)
    for p in 2:lim
        if !comp[p + 1]  # Adjust for 1-indexed
            for m in (p*p):p:N
                comp[m + 1] = true  # Adjust for 1-indexed
            end
        end
    end
    
    count = 0
    for i in 2:N
        if !comp[i + 1]  # Adjust for 1-indexed
            count += 1
        end
    end
    println(count)
end

function sort_ints(N::Int)
    arr = Vector{UInt32}(undef, N)
    s = [UInt32(123456789)]
    
    for i in 1:N
        arr[i] = lcg_next!(s)
    end
    
    sort!(arr)
    
    xorv = UInt64(arr[1]) ⊻ UInt64(arr[div(N, 2) + 1]) ⊻ UInt64(arr[N])
    total = UInt64(0)
    for v in arr
        total = (total + UInt64(v)) & UInt64(0xFFFFFFFFFFFFFFFF)
    end
    
    println("$(xorv & UInt64(0xFFFFFFFF)) $total")
end

function matmul(n::Int)
    N = n
    A = Matrix{Float64}(undef, N, N)
    B = Matrix{Float64}(undef, N, N)
    s = [UInt32(123456789)]
    inv = 1.0 / 4294967296.0
    
    # Fill matrices
    for i in 1:N
        for j in 1:N
            A[i, j] = lcg_next!(s) * inv
        end
    end
    for i in 1:N
        for j in 1:N
            B[i, j] = lcg_next!(s) * inv
        end
    end
    
    # Matrix multiplication
    C = A * B
    
    # Sum all elements
    total = sum(C)
    
    # Convert to hex representation
    bits = reinterpret(UInt64, total)
    println(string(bits, base=16, pad=16))
end

function kmp_search(N::Int, M::Int)
    T = Vector{UInt8}(undef, N)
    P = Vector{UInt8}(undef, M)
    s = [UInt32(123456789)]
    
    # Generate text and pattern
    for i in 1:N
        T[i] = UInt8('a') + UInt8(lcg_next!(s) % 26)
    end
    for i in 1:M
        P[i] = UInt8('a') + UInt8(lcg_next!(s) % 26)
    end
    
    # Build LPS array
    lps = zeros(Int, M)
    len = 0
    i = 2
    
    while i <= M
        if P[i] == P[len + 1]
            len += 1
            lps[i] = len
            i += 1
        elseif len != 0
            len = lps[len]
        else
            lps[i] = 0
            i += 1
        end
    end
    
    # KMP search
    count = 0
    i = 1
    j = 1
    
    while i <= N
        if T[i] == P[j]
            i += 1
            j += 1
            if j > M
                count += 1
                j = lps[j - 1] + 1
                if j == 0
                    j = 1
                end
            end
        elseif j != 1
            j = lps[j - 1] + 1
            if j == 0
                j = 1
            end
        else
            i += 1
        end
    end
    
    println(count)
end

function main()
    if length(ARGS) < 2
        println(stderr, "usage: julia multi.jl <task> <args...>")
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
        kmp_search(N, M)
    else
        println(stderr, "unknown task: $task")
        exit(1)
    end
end

main()