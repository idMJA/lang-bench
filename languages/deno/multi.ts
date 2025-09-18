// Deno version shares the same logic as Node/Bun.
function lcgNext(state: { v: number }): number {
  state.v = (Math.imul(1664525, state.v >>> 0) + 1013904223) >>> 0;
  return state.v >>> 0;
}

function sievePrimes(N: number): void {
  if (N < 2) { console.log(0); return; }
  const comp = new Uint8Array(N + 1);
  comp[0] = 1; comp[1] = 1;
  const lim = Math.floor(Math.sqrt(N));
  for (let p = 2; p <= lim; p++) {
    if (comp[p] === 0) {
      for (let m = p * p; m <= N; m += p) comp[m] = 1;
    }
  }
  let cnt = 0;
  for (let i = 2; i <= N; i++) if (comp[i] === 0) cnt++;
  console.log(cnt);
}

function sortInts(N: number): void {
  const s = { v: 123456789 };
  const a = new Uint32Array(N);
  for (let i = 0; i < N; i++) {
    lcgNext(s); a[i] = s.v;
  }
  a.sort();
  const xorv = (a[0] ^ a[Math.floor(N / 2)] ^ a[N - 1]) >>> 0;
  let total = 0n;
  for (let i = 0; i < N; i++) total += BigInt(a[i]);
  console.log(`${xorv} ${total}`);
}

function matmul(n: number): void {
  const N = n;
  const s = { v: 123456789 };
  const inv = 1.0 / 4294967296.0;
  const A = new Float64Array(N * N);
  const B = new Float64Array(N * N);
  const C = new Float64Array(N * N);
  
  for (let i = 0; i < N * N; i++) {
    lcgNext(s); A[i] = s.v * inv;
  }
  for (let i = 0; i < N * N; i++) {
    lcgNext(s); B[i] = s.v * inv;
  }
  
  for (let i = 0; i < N; i++) {
    const row = i * N;
    for (let k = 0; k < N; k++) {
      const aik = A[row + k];
      const col = k * N;
      for (let j = 0; j < N; j++) {
        C[row + j] += aik * B[col + j];
      }
    }
  }
  
  let sm = 0.0;
  for (let i = 0; i < N * N; i++) sm += C[i];
  const buf = new ArrayBuffer(8);
  const f64 = new Float64Array(buf);
  const u64 = new BigUint64Array(buf);
  f64[0] = sm;
  const bits = u64[0];
  console.log(bits.toString(16).padStart(16, '0'));
}

function kmp(N: number, M: number): void {
  const s = { v: 123456789 };
  const T = new Uint8Array(N);
  const P = new Uint8Array(M);
  for (let i = 0; i < N; i++) {
    lcgNext(s); T[i] = 97 + (s.v % 26);
  }
  for (let i = 0; i < M; i++) {
    lcgNext(s); P[i] = 97 + (s.v % 26);
  }
  const lps = new Int32Array(M);
  for (let i = 1, len = 0; i < M;) {
    if (P[i] === P[len]) {
      lps[i++] = ++len;
    } else if (len !== 0) {
      len = lps[len - 1];
    } else {
      lps[i++] = 0;
    }
  }
  let cnt = 0n;
  let i = 0, j = 0;
  while (i < N) {
    if (T[i] === P[j]) {
      i++; j++;
      if (j === M) {
        cnt++; j = lps[j - 1];
      }
    } else if (j !== 0) {
      j = lps[j - 1];
    } else {
      i++;
    }
  }
  console.log(cnt.toString());
}

function main(): void {
  if (Deno.args.length < 2) {
    console.error("usage: multi.ts <task> <args...>");
    Deno.exit(1);
  }
  
  const task = Deno.args[0];
  
  if (task === "sieve_primes") {
    sievePrimes(parseInt(Deno.args[1]));
  } else if (task === "sort_ints") {
    sortInts(parseInt(Deno.args[1]));
  } else if (task === "matmul_f64") {
    matmul(parseInt(Deno.args[1]));
  } else if (task === "string_kmp") {
    if (Deno.args.length < 3) {
      console.error("need N M");
      Deno.exit(1);
    }
    kmp(parseInt(Deno.args[1]), parseInt(Deno.args[2]));
  } else {
    console.error("unknown task:", task);
    Deno.exit(1);
  }
}

main();