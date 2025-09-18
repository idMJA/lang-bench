import os, math, algorithm, strformat, strutils

var s: uint32 = 123456789u32

proc lcgNext(): uint32 =
  s = (1664525u32 * s + 1013904223u32)
  return s

proc sievePrimes(N: int) =
  if N < 2:
    echo 0
    return
  
  var comp = newSeq[bool](N + 1)
  comp[0] = true
  comp[1] = true
  
  let lim = int(sqrt(float(N)))
  for p in 2..lim:
    if not comp[p]:
      var m = p * p
      while m <= N:
        comp[m] = true
        m += p
  
  var count = 0
  for i in 2..N:
    if not comp[i]:
      count += 1
  echo count

proc sortInts(N: int) =
  var arr = newSeq[uint32](N)
  s = 123456789u32
  
  for i in 0..<N:
    arr[i] = lcgNext()
  
  arr.sort()
  
  let xorv = arr[0] xor arr[N div 2] xor arr[N - 1]
  var total: uint64 = 0
  for v in arr:
    total += uint64(v)
  
  echo fmt"{xorv} {total}"

proc matmul(n: int) =
  let N = n
  var A = newSeq[float64](N * N)
  var B = newSeq[float64](N * N)
  var C = newSeq[float64](N * N)
  s = 123456789u32
  let inv = 1.0 / 4294967296.0
  
  # Fill matrices
  for i in 0..<(N * N):
    A[i] = float64(lcgNext()) * inv
  for i in 0..<(N * N):
    B[i] = float64(lcgNext()) * inv
  
  # Matrix multiplication
  for i in 0..<N:
    let row = i * N
    for k in 0..<N:
      let aik = A[row + k]
      let col = k * N
      for j in 0..<N:
        C[row + j] += aik * B[col + j]
  
  # Sum all elements
  var sum = 0.0
  for v in C:
    sum += v
  
  # Convert to hex - using cast to reinterpret bits
  let bits = cast[uint64](sum)
  echo fmt"{bits:016x}"

proc kmpSearch(N, M: int) =
  var T = newSeq[char](N)
  var P = newSeq[char](M)
  s = 123456789u32
  
  # Generate text and pattern
  for i in 0..<N:
    T[i] = char(ord('a') + int(lcgNext() mod 26))
  for i in 0..<M:
    P[i] = char(ord('a') + int(lcgNext() mod 26))
  
  # Build LPS array
  var lps = newSeq[int](M)
  var len = 0
  var i = 1
  
  while i < M:
    if P[i] == P[len]:
      len += 1
      lps[i] = len
      i += 1
    elif len != 0:
      len = lps[len - 1]
    else:
      lps[i] = 0
      i += 1
  
  # KMP search
  var count = 0
  i = 0
  var j = 0
  
  while i < N:
    if T[i] == P[j]:
      i += 1
      j += 1
      if j == M:
        count += 1
        j = lps[j - 1]
    elif j != 0:
      j = lps[j - 1]
    else:
      i += 1
  
  echo count

proc main() =
  let args = commandLineParams()
  if args.len < 2:
    stderr.writeLine("usage: multi <task> <args...>")
    quit(1)
  
  let task = args[0]
  
  case task:
  of "sieve_primes":
    let N = parseInt(args[1])
    sievePrimes(N)
  of "sort_ints":
    let N = parseInt(args[1])
    sortInts(N)
  of "matmul_f64":
    let n = parseInt(args[1])
    matmul(n)
  of "string_kmp":
    if args.len < 3:
      stderr.writeLine("need N M")
      quit(1)
    let N = parseInt(args[1])
    let M = parseInt(args[2])
    kmpSearch(N, M)
  else:
    stderr.writeLine("unknown task: " & task)
    quit(1)

when isMainModule:
  main()