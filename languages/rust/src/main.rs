use std::env;

#[inline]
fn lcg_next(state: &mut u32) -> u32 {
    *state = 1664525u32.wrapping_mul(*state).wrapping_add(1013904223u32);
    *state
}

fn sieve_primes(n: usize) {
    if n < 2 { println!("0"); return; }
    let mut comp = vec![false; n+1];
    comp[0]=true; comp[1]=true;
    let lim = (n as f64).sqrt() as usize;
    for p in 2..=lim {
        if !comp[p] {
            let mut m = p*p;
            while m <= n { comp[m]=true; m+=p; }
        }
    }
    let cnt = comp.iter().skip(2).filter(|&&c| !c).count();
    println!("{}", cnt);
}

fn sort_ints(n: usize) {
    let mut s: u32 = 123_456_789;
    let mut v: Vec<u32> = (0..n).map(|_| lcg_next(&mut s)).collect();
    v.sort_unstable();
    let xorv: u64 = v[0] as u64 ^ v[n/2] as u64 ^ v[n-1] as u64;
    let sum: u128 = v.iter().fold(0u128, |acc,&x| acc + x as u128);
    println!("{} {}", xorv, sum as u64);
}

fn matmul(n: usize) {
    let mut s: u32 = 123_456_789;
    let inv = 1.0f64/4294967296.0f64;
    let size = n*n;
    let mut a = vec![0.0f64; size];
    let mut b = vec![0.0f64; size];
    let mut c = vec![0.0f64; size];
    for i in 0..size { a[i] = (lcg_next(&mut s) as f64)*inv; }
    for i in 0..size { b[i] = (lcg_next(&mut s) as f64)*inv; }
    for i in 0..n {
        for k in 0..n {
            let aik = a[i*n+k];
            let row = i*n;
            let col = k*n;
            for j in 0..n {
                c[row+j] += aik * b[col+j];
            }
        }
    }
    let sum: f64 = c.iter().sum();
    let bits: u64 = sum.to_bits();
    println!("{:016x}", bits);
}

fn kmp(n: usize, m: usize) {
    let mut s: u32 = 123_456_789;
    let mut t = vec![0u8; n];
    let mut p = vec![0u8; m];
    for i in 0..n { t[i] = (b'a' + (lcg_next(&mut s)%26) as u8) as u8; }
    for i in 0..m { p[i] = (b'a' + (lcg_next(&mut s)%26) as u8) as u8; }
    // build lps
    let mut lps = vec![0usize; m];
    let (mut len, mut i) = (0usize, 1usize);
    while i < m {
        if p[i]==p[len] { len+=1; lps[i]=len; i+=1; }
        else if len!=0 { len = lps[len-1]; }
        else { lps[i]=0; i+=1; }
    }
    // search
    let (mut count, mut ii, mut jj) = (0usize,0usize,0usize);
    while ii < n {
        if t[ii]==p[jj] {
            ii+=1; jj+=1;
            if jj==m { count+=1; jj = lps[jj-1]; }
        } else if jj!=0 {
            jj = lps[jj-1];
        } else {
            ii+=1;
        }
    }
    println!("{}", count);
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len()<3 {
        eprintln!("usage: {} <task> <args...>", args[0]);
        std::process::exit(1);
    }
    let task = &args[1];
    match task.as_str() {
        "sieve_primes" => { let n: usize = args[2].parse().unwrap(); sieve_primes(n); }
        "sort_ints" => { let n: usize = args[2].parse().unwrap(); sort_ints(n); }
        "matmul_f64" => { let n: usize = args[2].parse().unwrap(); matmul(n); }
        "string_kmp" => {
            if args.len()<4 { eprintln!("need N M"); std::process::exit(1); }
            let n: usize = args[2].parse().unwrap();
            let m: usize = args[3].parse().unwrap();
            kmp(n,m);
        }
        _ => { eprintln!("unknown task"); std::process::exit(1); }
    }
}