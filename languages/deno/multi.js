'use strict';

function lcgNext(state) {
  state.v = (Math.imul(1664525, state.v >>> 0) + 1013904223) >>> 0;
  return state.v >>> 0;
}

function sievePrimes(N) {
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

function sortInts(N) {
  const arr = new Uint32Array(N);
  const s = { v: 123456789 };
  for (let i = 0; i < N; i++) arr[i] = lcgNext(s);
  // Convert to regular array for JS sort (stable, numeric)
  const a = Array.from(arr);
  a.sort((x, y) => x - y);
  const xorv = (a[0] ^ a[(N/2)|0] ^ a[N-1]) >>> 0;
  let sum = 0n;
  for (let i = 0; i < N; i++) sum += BigInt(a[i] >>> 0);
  console.log(`${xorv} ${sum & ((1n<<64n)-1n)}`);
}

function matmul(n) {
  const N = n|0;
  const A = new Float64Array(N*N);
  const B = new Float64Array(N*N);
  const C = new Float64Array(N*N);
  const s = { v: 123456789 };
  const inv = 1.0 / 4294967296.0;
  for (let i = 0; i < N*N; i++) A[i] = lcgNext(s) * inv;
  for (let i = 0; i < N*N; i++) B[i] = lcgNext(s) * inv;
  for (let i = 0; i < N; i++) {
    const row = i*N;
    for (let k = 0; k < N; k++) {
      const aik = A[row+k];
      const col = k*N;
      for (let j = 0; j < N; j++) {
        C[row+j] += aik * B[col+j];
      }
    }
  }
  let sum = 0.0;
  for (let i = 0; i < N*N; i++) sum += C[i];
  // print raw IEEE754 bits as hex
  const buf = new ArrayBuffer(8);
  const dv = new DataView(buf);
  dv.setFloat64(0, sum, false); // big-endian doesn't matter; we read as u64
  const hi = dv.getUint32(0, false), lo = dv.getUint32(4, false);
  const u = (BigInt(hi) << 32n) | BigInt(lo);
  console.log(u.toString(16).padStart(16,'0'));
}

function kmp(N, M) {
  const s = { v: 123456789 };
  const T = new Uint8Array(N);
  const P = new Uint8Array(M);
  for (let i = 0; i < N; i++) T[i] = 97 + (lcgNext(s) % 26);
  for (let i = 0; i < M; i++) P[i] = 97 + (lcgNext(s) % 26);
  const lps = new Int32Array(M);
  for (let i = 1, len = 0; i < M;) {
    if (P[i] === P[len]) { lps[i++] = ++len; }
    else if (len !== 0) { len = lps[len-1]; }
    else { lps[i++] = 0; }
  }
  let cnt = 0n, i = 0, j = 0;
  while (i < N) {
    if (T[i] === P[j]) { i++; j++; if (j === M) { cnt++; j = lps[j-1]; } }
    else if (j !== 0) { j = lps[j-1]; }
    else { i++; }
  }
  console.log(cnt.toString());
}

function main() {
  if (process.argv.length < 4) {
    console.error(`usage: node multi.js <task> <args...>`);
    process.exit(1);
  }
  const task = process.argv[2];
  if (task === 'sieve_primes') {
    const N = parseInt(process.argv[3],10);
    sievePrimes(N);
  } else if (task === 'sort_ints') {
    const N = parseInt(process.argv[3],10);
    sortInts(N);
  } else if (task === 'matmul_f64') {
    const n = parseInt(process.argv[3],10);
    matmul(n);
  } else if (task === 'string_kmp') {
    if (process.argv.length < 5) { console.error('need N M'); process.exit(1); }
    const N = parseInt(process.argv[3],10);
    const M = parseInt(process.argv[4],10);
    kmp(N,M);
  } else {
    console.error('unknown task');
    process.exit(1);
  }
}
main();