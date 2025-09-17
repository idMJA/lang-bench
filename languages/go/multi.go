package main

import (
	"encoding/binary"
	"fmt"
	"log"
	"math"
	"os"
	"sort"
	"strconv"
)

func lcgNext(s *uint32) uint32 {
	*s = 1664525*(*s) + 1013904223
	return *s
}

func sievePrimes(N int) {
	if N < 2 {
		fmt.Println(0)
		return
	}
	comp := make([]bool, N+1)
	comp[0], comp[1] = true, true
	lim := int(math.Sqrt(float64(N)))
	for p := 2; p <= lim; p++ {
		if !comp[p] {
			for m := p * p; m <= N; m += p {
				comp[m] = true
			}
		}
	}
	cnt := 0
	for i := 2; i <= N; i++ {
		if !comp[i] {
			cnt++
		}
	}
	fmt.Println(cnt)
}

func sortInts(N int) {
	arr := make([]uint32, N)
	s := uint32(123456789)
	for i := 0; i < N; i++ {
		arr[i] = lcgNext(&s)
	}
	sort.Slice(arr, func(i, j int) bool { return arr[i] < arr[j] })
	xorv := uint64(arr[0]) ^ uint64(arr[N/2]) ^ uint64(arr[N-1])
	var sum uint64 = 0
	for _, v := range arr {
		sum += uint64(v)
	}
	fmt.Printf("%d %d\n", xorv, sum)
}

func matmul(n int) {
	N := n
	A := make([]float64, N*N)
	B := make([]float64, N*N)
	C := make([]float64, N*N)
	s := uint32(123456789)
	inv := 1.0 / 4294967296.0
	for i := 0; i < N*N; i++ {
		A[i] = float64(lcgNext(&s)) * inv
	}
	for i := 0; i < N*N; i++ {
		B[i] = float64(lcgNext(&s)) * inv
	}
	for i := 0; i < N; i++ {
		row := i * N
		for k := 0; k < N; k++ {
			aik := A[row+k]
			col := k * N
			for j := 0; j < N; j++ {
				C[row+j] += aik * B[col+j]
			}
		}
	}
	sum := 0.0
	for i := 0; i < N*N; i++ {
		sum += C[i]
	}
	// print hex bit pattern
	u := math.Float64bits(sum)
	buf := make([]byte, 8)
	binary.BigEndian.PutUint64(buf, u)
	fmt.Printf("%016x\n", u)
}

func kmp(n, m int) {
	T := make([]byte, n)
	P := make([]byte, m)
	s := uint32(123456789)
	for i := 0; i < n; i++ {
		T[i] = byte('a' + (lcgNext(&s) % 26))
	}
	for i := 0; i < m; i++ {
		P[i] = byte('a' + (lcgNext(&s) % 26))
	}
	// build lps
	lps := make([]int, m)
	for i, l := 1, 0; i < m; {
		if P[i] == P[l] {
			l++
			lps[i] = l
			i++
		} else if l != 0 {
			l = lps[l-1]
		} else {
			lps[i] = 0
			i++
		}
	}
	// search
	count := 0
	for i, j := 0, 0; i < n; {
		if T[i] == P[j] {
			i++
			j++
			if j == m {
				count++
				j = lps[j-1]
			}
		} else if j != 0 {
			j = lps[j-1]
		} else {
			i++
		}
	}
	fmt.Println(count)
}

func main() {
	if len(os.Args) < 3 {
		log.Fatalf("usage: %s <task> <args...>", os.Args[0])
	}
	task := os.Args[1]
	switch task {
	case "sieve_primes":
		N, _ := strconv.Atoi(os.Args[2])
		sievePrimes(N)
	case "sort_ints":
		N, _ := strconv.Atoi(os.Args[2])
		sortInts(N)
	case "matmul_f64":
		n, _ := strconv.Atoi(os.Args[2])
		matmul(n)
	case "string_kmp":
		if len(os.Args) < 4 {
			log.Fatalf("need N M")
		}
		N, _ := strconv.Atoi(os.Args[2])
		M, _ := strconv.Atoi(os.Args[3])
		kmp(N, M)
	default:
		log.Fatalf("unknown task: %s", task)
	}
}