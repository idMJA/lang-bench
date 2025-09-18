const std = @import("std");
const print = std.debug.print;
const parseUnsigned = std.fmt.parseUnsigned;

fn lcgNext(seed: *u32) u32 {
    seed.* = seed.* *% 1664525 +% 1013904223;
    return seed.*;
}

fn sievePrimes(N: u32) !void {
    if (N < 2) {
        print("0\n");
        return;
    }
    
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    var comp = try allocator.alloc(bool, N + 1);
    for (comp) |*c| c.* = false;
    comp[0] = true;
    comp[1] = true;
    
    const lim = @as(u32, @intFromFloat(@sqrt(@as(f64, @floatFromInt(N)))));
    var p: u32 = 2;
    while (p <= lim) : (p += 1) {
        if (!comp[p]) {
            var m = p * p;
            while (m <= N) : (m += p) {
                comp[m] = true;
            }
        }
    }
    
    var cnt: u32 = 0;
    var i: u32 = 2;
    while (i <= N) : (i += 1) {
        if (!comp[i]) cnt += 1;
    }
    print("{}\n", .{cnt});
}

fn sortInts(N: u32) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    var s: u32 = 123456789;
    var a = try allocator.alloc(u32, N);
    
    for (a) |*val| {
        s = lcgNext(&s);
        val.* = s;
    }
    
    std.sort.heap(u32, a, {}, comptime std.sort.asc(u32));
    
    const xorv = (a[0] ^ a[N / 2] ^ a[N - 1]);
    var total: u64 = 0;
    for (a) |val| {
        total +%= val;
    }
    print("{} {}\n", .{ xorv, total });
}

fn matmul(n: u32) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    const N = n;
    var s: u32 = 123456789;
    const inv = 1.0 / 4294967296.0;
    
    var A = try allocator.alloc(f64, N * N);
    var B = try allocator.alloc(f64, N * N);
    var C = try allocator.alloc(f64, N * N);
    
    for (A) |*val| {
        s = lcgNext(&s);
        val.* = @as(f64, @floatFromInt(s)) * inv;
    }
    for (B) |*val| {
        s = lcgNext(&s);
        val.* = @as(f64, @floatFromInt(s)) * inv;
    }
    for (C) |*val| val.* = 0.0;
    
    var i: u32 = 0;
    while (i < N) : (i += 1) {
        const row = i * N;
        var k: u32 = 0;
        while (k < N) : (k += 1) {
            const aik = A[row + k];
            const col = k * N;
            var j: u32 = 0;
            while (j < N) : (j += 1) {
                C[row + j] += aik * B[col + j];
            }
        }
    }
    
    var sm: f64 = 0.0;
    for (C) |val| sm += val;
    
    const bits = @as(u64, @bitCast(sm));
    print("{x:0>16}\n", .{bits});
}

fn kmp(N: u32, M: u32) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    var s: u32 = 123456789;
    var T = try allocator.alloc(u8, N);
    var P = try allocator.alloc(u8, M);
    
    for (T) |*val| {
        s = lcgNext(&s);
        val.* = 97 + @as(u8, @intCast(s % 26));
    }
    for (P) |*val| {
        s = lcgNext(&s);
        val.* = 97 + @as(u8, @intCast(s % 26));
    }
    
    var lps = try allocator.alloc(u32, M);
    for (lps) |*val| val.* = 0;
    
    var length: u32 = 0;
    var i: u32 = 1;
    while (i < M) {
        if (P[i] == P[length]) {
            length += 1;
            lps[i] = length;
            i += 1;
        } else if (length != 0) {
            length = lps[length - 1];
        } else {
            lps[i] = 0;
            i += 1;
        }
    }
    
    var cnt: u32 = 0;
    i = 0;
    var j: u32 = 0;
    while (i < N) {
        if (T[i] == P[j]) {
            i += 1;
            j += 1;
            if (j == M) {
                cnt += 1;
                j = lps[j - 1];
            }
        } else if (j != 0) {
            j = lps[j - 1];
        } else {
            i += 1;
        }
    }
    print("{}\n", .{cnt});
}

pub fn main() !void {
    const args = std.process.argsAlloc(std.heap.page_allocator) catch {
        std.debug.print("Failed to get args\n", .{});
        return;
    };
    defer std.process.argsFree(std.heap.page_allocator, args);
    
    if (args.len < 3) {
        std.debug.print("usage: multi <task> <args...>\n", .{});
        std.process.exit(1);
    }
    
    const task = args[1];
    
    if (std.mem.eql(u8, task, "sieve_primes")) {
        const N = parseUnsigned(u32, args[2], 10) catch {
            std.debug.print("Invalid number: {s}\n", .{args[2]});
            std.process.exit(1);
        };
        try sievePrimes(N);
    } else if (std.mem.eql(u8, task, "sort_ints")) {
        const N = parseUnsigned(u32, args[2], 10) catch {
            std.debug.print("Invalid number: {s}\n", .{args[2]});
            std.process.exit(1);
        };
        try sortInts(N);
    } else if (std.mem.eql(u8, task, "matmul_f64")) {
        const n = parseUnsigned(u32, args[2], 10) catch {
            std.debug.print("Invalid number: {s}\n", .{args[2]});
            std.process.exit(1);
        };
        try matmul(n);
    } else if (std.mem.eql(u8, task, "string_kmp")) {
        if (args.len < 4) {
            std.debug.print("need N M\n", .{});
            std.process.exit(1);
        }
        const N = parseUnsigned(u32, args[2], 10) catch {
            std.debug.print("Invalid number: {s}\n", .{args[2]});
            std.process.exit(1);
        };
        const M = parseUnsigned(u32, args[3], 10) catch {
            std.debug.print("Invalid number: {s}\n", .{args[3]});
            std.process.exit(1);
        };
        try kmp(N, M);
    } else {
        std.debug.print("unknown task: {s}\n", .{task});
        std.process.exit(1);
    }
}