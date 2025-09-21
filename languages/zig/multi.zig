const std = @import("std");

fn lcg_next(s: *u32) u32 {
    s.* = 1664525 * s.* + 1013904223;
    return s.*;
}

fn sieve_primes(N: u64) !void {
    if (N < 2) {
        std.debug.print("0\n", .{});
        return;
    }
    var allocator = std.heap.page_allocator;
    var comp = try allocator.alloc(u8, N + 1);
    defer allocator.free(comp);
    @memset(comp, 0);
    comp[0] = 1;
    comp[1] = 1;

    const lim_f = std.math.sqrt(@as(f64, @floatFromInt(N)));
    const lim = @as(u64, @intFromFloat(lim_f));

    var p: u64 = 2;
    while (p <= lim) : (p += 1) {
        if (comp[p] == 0) {
            var m = p * p;
            while (m <= N) : (m += p) comp[m] = 1;
        }
    }

    var cnt: u64 = 0;
    var i: u64 = 2;
    while (i <= N) : (i += 1) {
        if (comp[i] == 0) cnt += 1;
    }
    std.debug.print("{}\n", .{cnt});
}

fn sort_ints(N: u64) !void {
    var allocator = std.heap.page_allocator;
    var arr = try allocator.alloc(u32, N);
    defer allocator.free(arr);

    var s: u32 = 123456789;
    var i: u64 = 0;
    while (i < N) : (i += 1) arr[i] = lcg_next(&s);

    // Zig 0.15.x: std.mem.sort + std.sort.asc
    std.mem.sort(u32, arr, {}, comptime std.sort.asc(u32));

    const xorv: u64 = @as(u64, arr[0]) ^ @as(u64, arr[N / 2]) ^ @as(u64, arr[N - 1]);
    var sum: u64 = 0;
    i = 0;
    while (i < N) : (i += 1) sum += arr[i];

    std.debug.print("{} {}\n", .{ xorv, sum });
}

fn matmul_f64(n: u64) !void {
    const N = n;
    var allocator = std.heap.page_allocator;

    var A = try allocator.alloc(f64, N * N);
    var B = try allocator.alloc(f64, N * N);
    var C = try allocator.alloc(f64, N * N);
    defer allocator.free(A);
    defer allocator.free(B);
    defer allocator.free(C);

    @memset(C, 0.0);

    var s: u32 = 123456789;
    const inv: f64 = 1.0 / 4294967296.0;

    var idx: u64 = 0;
    while (idx < N * N) : (idx += 1) A[idx] = @as(f64, @floatFromInt(lcg_next(&s))) * inv;
    idx = 0;
    while (idx < N * N) : (idx += 1) B[idx] = @as(f64, @floatFromInt(lcg_next(&s))) * inv;

    var i: u64 = 0;
    while (i < N) : (i += 1) {
        var k: u64 = 0;
        while (k < N) : (k += 1) {
            const aik = A[i * N + k];
            var j: u64 = 0;
            while (j < N) : (j += 1) {
                C[i * N + j] += aik * B[k * N + j];
            }
        }
    }

    var sum: f64 = 0.0;
    idx = 0;
    while (idx < N * N) : (idx += 1) sum += C[idx];

    const bits: u64 = @bitCast(sum);
    std.debug.print("{x:0>16}\n", .{bits});
}

fn kmp(N: u64, M: u64) !void {
    var allocator = std.heap.page_allocator;

    var T = try allocator.alloc(u8, N);
    var P = try allocator.alloc(u8, M);
    defer allocator.free(T);
    defer allocator.free(P);

    var s: u32 = 123456789;
    var i: u64 = 0;
    while (i < N) : (i += 1) {
        const c_val = 97 + (lcg_next(&s) % 26);
        T[i] = @as(u8, @intCast(c_val));
    }
    i = 0;
    while (i < M) : (i += 1) {
        const c_val = 97 + (lcg_next(&s) % 26);
        P[i] = @as(u8, @intCast(c_val));
    }

    var lps = try allocator.alloc(u64, M);
    defer allocator.free(lps);

    var len: u64 = 0;
    i = 1;
    while (i < M) : (i += 1) {
        if (P[i] == P[len]) {
            len += 1;
            lps[i] = len;
        } else if (len != 0) {
            len = lps[len - 1];
            i -= 1;
        } else {
            lps[i] = 0;
        }
    }

    var cnt: u64 = 0;
    var ii: u64 = 0;
    var jj: u64 = 0;
    while (ii < N) {
        if (T[ii] == P[jj]) {
            ii += 1;
            jj += 1;
            if (jj == M) {
                cnt += 1;
                jj = lps[jj - 1];
            }
        } else if (jj != 0) {
            jj = lps[jj - 1];
        } else {
            ii += 1;
        }
    }
    std.debug.print("{}\n", .{cnt});
}

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.heap.page_allocator.free(args);

    if (args.len < 3) {
        std.debug.print("usage: multi <task> <args...>\n", .{});
        std.process.exit(1);
    }

    const task = args[1];
    if (std.mem.eql(u8, task, "sieve_primes")) {
        const N = try std.fmt.parseInt(u64, args[2], 10);
        try sieve_primes(N);
    } else if (std.mem.eql(u8, task, "sort_ints")) {
        const N = try std.fmt.parseInt(u64, args[2], 10);
        try sort_ints(N);
    } else if (std.mem.eql(u8, task, "matmul_f64")) {
        const n = try std.fmt.parseInt(u64, args[2], 10);
        try matmul_f64(n);
    } else if (std.mem.eql(u8, task, "string_kmp")) {
        if (args.len < 4) {
            std.debug.print("need N M\n", .{});
            std.process.exit(1);
        }
        const N = try std.fmt.parseInt(u64, args[2], 10);
        const M = try std.fmt.parseInt(u64, args[3], 10);
        try kmp(N, M);
    } else {
        std.debug.print("unknown task: {s}\n", .{task});
        std.process.exit(1);
    }
}