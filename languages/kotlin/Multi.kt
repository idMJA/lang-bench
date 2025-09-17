import kotlin.math.sqrt
import kotlin.system.exitProcess

fun lcgNext(s: IntArray): Int {
    val v = 1664525 * s[0] + 1013904223
    s[0] = v
    return v
}

fun sievePrimes(N: Int): Int {
    if (N < 2) return 0
    val comp = BooleanArray(N + 1)
    comp[0] = true; comp[1] = true
    val lim = sqrt(N.toDouble()).toInt()
    var p = 2
    while (p <= lim) {
        if (!comp[p]) {
            var m = p * p
            while (m <= N) {
                comp[m] = true
                m += p
            }
        }
        p++
    }
    var cnt = 0
    for (i in 2..N) if (!comp[i]) cnt++
    return cnt
}

fun sortInts(N: Int): Pair<Long, Long> {
    val a = IntArray(N)
    val s = intArrayOf(123456789)
    for (i in 0 until N) a[i] = lcgNext(s)
    a.sort()
    val xorv = (a[0].toLong() and 0xffffffffL) xor (a[N/2].toLong() and 0xffffffffL) xor (a[N-1].toLong() and 0xffffffffL)
    var sum = 0L
    for (v in a) sum += (v.toLong() and 0xffffffffL)
    return Pair(xorv, sum)
}

fun matmul(n: Int): String {
    val N = n
    val A = DoubleArray(N*N)
    val B = DoubleArray(N*N)
    val C = DoubleArray(N*N)
    val s = intArrayOf(123456789)
    val inv = 1.0/4294967296.0
    for (i in 0 until N*N) A[i] = (lcgNext(s).toLong() and 0xffffffffL).toDouble()*inv
    for (i in 0 until N*N) B[i] = (lcgNext(s).toLong() and 0xffffffffL).toDouble()*inv
    for (i in 0 until N) {
        val row = i*N
        for (k in 0 until N) {
            val aik = A[row+k]
            val col = k*N
            for (j in 0 until N) {
                C[row+j] += aik * B[col+j]
            }
        }
    }
    var sum = 0.0
    for (v in C) sum += v
    val bits = java.lang.Double.doubleToRawLongBits(sum)
    return java.lang.String.format("%016x", bits)
}

fun kmp(N: Int, M: Int): Long {
    val T = ByteArray(N)
    val P = ByteArray(M)
    val s = intArrayOf(123456789)
    for (i in 0 until N) T[i] = ('a'.code + (lcgNext(s) % 26)).toByte()
    for (i in 0 until M) P[i] = ('a'.code + (lcgNext(s) % 26)).toByte()
    val lps = IntArray(M)
    var i = 1; var len = 0
    while (i < M) {
        if (P[i]==P[len]) { len++; lps[i]=len; i++ }
        else if (len!=0) { len = lps[len-1] }
        else { lps[i]=0; i++ }
    }
    var cnt = 0L
    var ii = 0; var jj = 0
    while (ii < N) {
        if (T[ii]==P[jj]) {
            ii++; jj++
            if (jj==M) { cnt++; jj = lps[jj-1] }
        } else if (jj!=0) {
            jj = lps[jj-1]
        } else {
            ii++
        }
    }
    return cnt
}

object Multi {
    @JvmStatic
    fun main(args: Array<String>) {
        if (args.size < 2) {
            System.err.println("usage: Multi <task> <args...>")
            exitProcess(1)
        }
        when (args[0]) {
            "sieve_primes" -> {
                val N = args[1].toInt()
                println(sievePrimes(N))
            }
            "sort_ints" -> {
                val N = args[1].toInt()
                val r = sortInts(N)
                println("${r.first} ${r.second}")
            }
            "matmul_f64" -> {
                val n = args[1].toInt()
                println(matmul(n))
            }
            "string_kmp" -> {
                if (args.size < 3) { System.err.println("need N M"); exitProcess(1) }
                val N = args[1].toInt()
                val M = args[2].toInt()
                println(kmp(N,M))
            }
            else -> {
                System.err.println("unknown task")
                exitProcess(1)
            }
        }
    }
}