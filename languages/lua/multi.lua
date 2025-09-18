#!/usr/bin/env lua5.4

-- LCG Next Function
function lcg_next(s)
    s[1] = (1664525 * s[1] + 1013904223) & 0xFFFFFFFF
    return s[1]
end

-- Sieve of Eratosthenes for prime counting
function sieve_primes(N)
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
    
    local count = 0
    for i = 2, N do
        if not comp[i] then
            count = count + 1
        end
    end
    print(count)
end

-- Sort integers and compute xor and sum
function sort_ints(N)
    local arr = {}
    local s = {123456789}
    
    for i = 1, N do
        arr[i] = lcg_next(s)
    end
    
    table.sort(arr)
    
    local xorv = arr[1] ~ arr[math.floor(N/2) + 1] ~ arr[N]
    local sum = 0
    for i = 1, N do
        sum = (sum + arr[i]) & 0xFFFFFFFFFFFFFFFF
    end
    
    print(string.format("%d %d", xorv & 0xFFFFFFFF, sum))
end

-- Matrix multiplication
function matmul(n)
    local N = n
    local A = {}
    local B = {}
    local C = {}
    local s = {123456789}
    local inv = 1.0 / 4294967296.0
    
    -- Initialize matrices
    for i = 1, N*N do
        A[i] = lcg_next(s) * inv
        B[i] = lcg_next(s) * inv
        C[i] = 0.0
    end
    
    -- Matrix multiplication
    for i = 0, N-1 do
        local row = i * N
        for k = 0, N-1 do
            local aik = A[row + k + 1]
            local col = k * N
            for j = 0, N-1 do
                C[row + j + 1] = C[row + j + 1] + aik * B[col + j + 1]
            end
        end
    end
    
    -- Sum all elements
    local sum = 0.0
    for i = 1, N*N do
        sum = sum + C[i]
    end
    
    -- Convert to hex (Lua doesn't have direct bit conversion, use string formatting)
    local function double_to_hex(num)
        -- Simple approach: use string.format with %a which gives hex representation
        local hex_str = string.format("%a", num)
        -- Extract the hex part and format it as 64-bit
        local mantissa, exp = hex_str:match("0x1%.([%w]+)p([%+%-]?%d+)")
        if mantissa and exp then
            -- This is a simplified approach - for exact compliance we'd need more precise conversion
            return string.format("%016x", math.floor(num * 2^52) & 0xFFFFFFFFFFFFFFFF)
        else
            -- Fallback method
            return string.format("%016x", math.floor(num) & 0xFFFFFFFFFFFFFFFF)
        end
    end
    
    -- Use a more direct approach - pack as double and unpack as long
    local packed = string.pack("d", sum)
    local unpacked = string.unpack("I8", packed)
    print(string.format("%016x", unpacked))
end

-- KMP string matching
function kmp(N, M)
    local T = {}
    local P = {}
    local s = {123456789}
    
    -- Generate text and pattern
    for i = 1, N do
        T[i] = string.char(string.byte('a') + (lcg_next(s) % 26))
    end
    for i = 1, M do
        P[i] = string.char(string.byte('a') + (lcg_next(s) % 26))
    end
    
    -- Convert to strings for easier processing
    local text = table.concat(T)
    local pattern = table.concat(P)
    
    -- Build LPS array
    local lps = {}
    for i = 1, M do lps[i] = 0 end
    
    local len = 0
    local i = 2
    while i <= M do
        if pattern:sub(i, i) == pattern:sub(len + 1, len + 1) then
            len = len + 1
            lps[i] = len
            i = i + 1
        elseif len ~= 0 then
            len = lps[len]
        else
            lps[i] = 0
            i = i + 1
        end
    end
    
    -- KMP search
    local count = 0
    i = 1
    local j = 1
    while i <= N do
        if text:sub(i, i) == pattern:sub(j, j) then
            i = i + 1
            j = j + 1
            if j > M then
                count = count + 1
                j = lps[j - 1] + 1
                if j == 1 then j = 1 end
            end
        elseif j ~= 1 then
            j = lps[j - 1] + 1
            if j == 1 then j = 1 end
        else
            i = i + 1
        end
    end
    
    print(count)
end

-- Main function
function main()
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