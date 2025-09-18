#!/usr/bin/env lua

local function lcg_next(s)
    return (s * 1664525 + 1013904223) & 0xFFFFFFFF
end

local function sieve_primes(N)
    if N < 2 then
        print(0)
        return
    end
    
    local comp = {}
    for i = 0, N do comp[i] = false end
    comp[0] = true
    comp[1] = true
    
    local lim = math.floor(math.sqrt(N))
    for p = 2, lim do
        if not comp[p] then
            local m = p * p
            while m <= N do
                comp[m] = true
                m = m + p
            end
        end
    end
    
    local cnt = 0
    for i = 2, N do
        if not comp[i] then
            cnt = cnt + 1
        end
    end
    print(cnt)
end

local function sort_ints(N)
    local s = 123456789
    local a = {}
    
    for i = 1, N do
        s = lcg_next(s)
        a[i] = s
    end
    
    table.sort(a)
    
    local xorv = (a[1] ~ a[math.floor(N/2) + 1] ~ a[N]) & 0xFFFFFFFF
    local total = 0
    for i = 1, N do
        total = (total + (a[i] & 0xFFFFFFFF)) & 0xFFFFFFFFFFFFFFFF
    end
    print(string.format("%u %u", xorv, total))
end

local function matmul(n)
    local N = n
    local s = 123456789
    local inv = 1.0 / 4294967296.0
    
    local A = {}
    local B = {}
    local C = {}
    
    for i = 1, N * N do
        s = lcg_next(s)
        A[i] = s * inv
    end
    for i = 1, N * N do
        s = lcg_next(s)
        B[i] = s * inv
    end
    for i = 1, N * N do
        C[i] = 0.0
    end
    
    for i = 0, N - 1 do
        local row = i * N
        for k = 0, N - 1 do
            local aik = A[row + k + 1]
            local col = k * N
            for j = 0, N - 1 do
                C[row + j + 1] = C[row + j + 1] + aik * B[col + j + 1]
            end
        end
    end
    
    local sm = 0.0
    for i = 1, N * N do
        sm = sm + C[i]
    end
    
    -- Convert float64 to hex representation
    local function double_to_hex(d)
        local s = string.pack(">d", d)
        return string.format("%016x", string.unpack(">I8", s))
    end
    
    print(double_to_hex(sm))
end

local function kmp(N, M)
    local s = 123456789
    local T = {}
    local P = {}
    
    for i = 1, N do
        s = lcg_next(s)
        T[i] = string.char(97 + (s % 26))
    end
    for i = 1, M do
        s = lcg_next(s)
        P[i] = string.char(97 + (s % 26))
    end
    
    local lps = {}
    for i = 1, M do lps[i] = 0 end
    
    local length = 0
    local i = 2
    while i <= M do
        if P[i] == P[length + 1] then
            length = length + 1
            lps[i] = length
            i = i + 1
        elseif length ~= 0 then
            length = lps[length]
        else
            lps[i] = 0
            i = i + 1
        end
    end
    
    local cnt = 0
    i = 1
    local j = 1
    while i <= N do
        if T[i] == P[j] then
            i = i + 1
            j = j + 1
            if j > M then
                cnt = cnt + 1
                j = lps[j - 1] + 1
            end
        elseif j > 1 then
            j = lps[j - 1] + 1
        else
            i = i + 1
        end
    end
    print(cnt)
end

local function main()
    if #arg < 2 then
        io.stderr:write("usage: multi.lua <task> <args...>\n")
        os.exit(1)
    end
    
    local task = arg[1]
    
    if task == "sieve_primes" then
        local N = tonumber(arg[2])
        sieve_primes(N)
    elseif task == "sort_ints" then
        local N = tonumber(arg[2])
        sort_ints(N)
    elseif task == "matmul_f64" then
        local n = tonumber(arg[2])
        matmul(n)
    elseif task == "string_kmp" then
        if #arg < 3 then
            io.stderr:write("need N M\n")
            os.exit(1)
        end
        local N = tonumber(arg[2])
        local M = tonumber(arg[3])
        kmp(N, M)
    else
        io.stderr:write("unknown task: " .. task .. "\n")
        os.exit(1)
    end
end

main()