import Foundation

@inline(__always)
func lcgNext(_ s: inout UInt32) -> UInt32 {
    s = 1664525 &* s &+ 1013904223
    return s
}

func sievePrimes(_ N: Int) {
    if N < 2 { print(0); return }
    var comp = [Bool](repeating: false, count: N+1)
    comp[0]=true; comp[1]=true
    let lim = Int(Double(N).squareRoot())
    var p=2
    while p<=lim {
        if !comp[p] {
            var m = p*p
            while m<=N { comp[m]=true; m+=p }
        }
        p+=1
    }
    var cnt=0
    for i in 2...N { if !comp[i] { cnt+=1 } }
    print(cnt)
}

func sortInts(_ N: Int) {
    var s: UInt32 = 123456789
    var arr = [UInt32](repeating: 0, count: N)
    for i in 0..<N { arr[i] = lcgNext(&s) }
    arr.sort()
    let xorv = UInt64(arr[0]) ^ UInt64(arr[N/2]) ^ UInt64(arr[N-1])
    var sum: UInt64 = 0
    for v in arr { sum &+= UInt64(v) }
    print("\(xorv) \(sum)")
}

func matmul(_ n: Int) {
    let N = n
    var A = [Double](repeating: 0, count: N*N)
    var B = [Double](repeating: 0, count: N*N)
    var C = [Double](repeating: 0, count: N*N)
    var s: UInt32 = 123456789
    let inv = 1.0/4294967296.0
    for i in 0..<(N*N) { A[i] = Double(lcgNext(&s)) * inv }
    for i in 0..<(N*N) { B[i] = Double(lcgNext(&s)) * inv }
    for i in 0..<N {
        let row = i*N
        for k in 0..<N {
            let aik = A[row+k]
            let col = k*N
            for j in 0..<N {
                C[row+j] += aik * B[col+j]
            }
        }
    }
    var sum = 0.0
    for v in C { sum += v }
    let bits = sum.bitPattern
    print(String(format:"%016llx", bits))
}

func kmp(_ N: Int, _ M: Int) {
    var s: UInt32 = 123456789
    var T = [UInt8](repeating: 0, count: N)
    var P = [UInt8](repeating: 0, count: M)
    for i in 0..<N { T[i] = UInt8(97 + Int(lcgNext(&s) % 26)) }
    for i in 0..<M { P[i] = UInt8(97 + Int(lcgNext(&s) % 26)) }
    var lps = [Int](repeating: 0, count: M)
    var len = 0
    var i = 1
    while i < M {
        if P[i]==P[len] { len+=1; lps[i]=len; i+=1 }
        else if len != 0 { len = lps[len-1] }
        else { lps[i]=0; i+=1 }
    }
    var cnt: UInt64 = 0
    var ii = 0, jj = 0
    while ii < N {
        if T[ii]==P[jj] {
            ii+=1; jj+=1
            if jj==M { cnt+=1; jj = lps[jj-1] }
        } else if jj != 0 {
            jj = lps[jj-1]
        } else {
            ii+=1
        }
    }
    print(cnt)
}

let args = CommandLine.arguments
if args.count < 3 {
    FileHandle.standardError.write(Data("usage: multi <task> <args...>\n".utf8))
    exit(1)
}
let task = args[1]
switch task {
case "sieve_primes":
    sievePrimes(Int(args[2])!)
case "sort_ints":
    sortInts(Int(args[2])!)
case "matmul_f64":
    matmul(Int(args[2])!)
case "string_kmp":
    if args.count < 4 { FileHandle.standardError.write(Data("need N M\n".utf8)); exit(1) }
    kmp(Int(args[2])!, Int(args[3])!)
default:
    FileHandle.standardError.write(Data("unknown task\n".utf8))
    exit(1)
}