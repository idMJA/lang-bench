#!/usr/bin/env elixir

defmodule Multi do
  @seed 123456789

  # LCG implementation with state passed around
  def lcg_next(s) do
    new_s = rem(1664525 * s + 1013904223, 4294967296)
    {new_s, new_s}
  end

  def sieve_primes(n) when n < 2 do
    IO.puts(0)
  end

  def sieve_primes(n) do
    comp = :ets.new(:comp, [:set])
    :ets.insert(comp, {0, true})
    :ets.insert(comp, {1, true})
    
    lim = trunc(:math.sqrt(n))
    
    for p <- 2..lim do
      case :ets.lookup(comp, p) do
        [] ->
          # p is prime, mark multiples
          Stream.iterate(p * p, &(&1 + p))
          |> Stream.take_while(&(&1 <= n))
          |> Enum.each(fn m -> :ets.insert(comp, {m, true}) end)
        _ -> :ok
      end
    end
    
    count = Enum.count(2..n, fn i -> 
      case :ets.lookup(comp, i) do
        [] -> true
        _ -> false
      end
    end)
    
    :ets.delete(comp)
    IO.puts(count)
  end

  def sort_ints(n) do
    {arr, _} = Enum.map_reduce(1..n, @seed, fn _, s ->
      {new_s, val} = lcg_next(s)
      {val, new_s}
    end)
    
    sorted = Enum.sort(arr)
    
    xorv = Enum.at(sorted, 0) |> Bitwise.bxor(Enum.at(sorted, div(n, 2))) |> Bitwise.bxor(Enum.at(sorted, n - 1))
    xorv = Bitwise.band(xorv, 0xFFFFFFFF)
    
    total = Enum.reduce(sorted, 0, fn x, acc -> Bitwise.band(acc + x, 0xFFFFFFFFFFFFFFFF) end)
    
    IO.puts("#{xorv} #{total}")
  end

  def matmul(n) do
    # Generate matrix A
    {a_vals, last_s} = Enum.map_reduce(1..(n*n), @seed, fn _, s ->
      {new_s, val} = lcg_next(s)
      {val / 4294967296.0, new_s}
    end)
    
    # Generate matrix B
    {b_vals, _} = Enum.map_reduce(1..(n*n), last_s, fn _, s ->
      {new_s, val} = lcg_next(s)
      {val / 4294967296.0, new_s}
    end)
    
    # Convert to matrices (list of lists)
    a_matrix = Enum.chunk_every(a_vals, n)
    b_matrix = Enum.chunk_every(b_vals, n)
    
    # Matrix multiplication
    c_matrix = for i <- 0..(n-1) do
      for j <- 0..(n-1) do
        Enum.reduce(0..(n-1), 0.0, fn k, acc ->
          acc + Enum.at(Enum.at(a_matrix, i), k) * Enum.at(Enum.at(b_matrix, k), j)
        end)
      end
    end
    
    # Sum all elements
    sum = c_matrix |> List.flatten() |> Enum.sum()
    
    # Convert to hex (Elixir doesn't have direct bit manipulation for floats)
    # Use binary pattern matching for IEEE 754 representation
    <<bits::64>> = <<sum::float>>
    IO.puts(:io_lib.format("~16.16.0b", [bits]) |> List.to_string())
  end

  def kmp_search(n, m) do
    # Generate text
    {text, last_s} = Enum.map_reduce(1..n, @seed, fn _, s ->
      {new_s, val} = lcg_next(s)
      {?a + rem(val, 26), new_s}
    end)
    
    # Generate pattern
    {pattern, _} = Enum.map_reduce(1..m, last_s, fn _, s ->
      {new_s, val} = lcg_next(s)
      {?a + rem(val, 26), new_s}
    end)
    
    # Build LPS array
    lps = build_lps(pattern)
    
    # KMP search
    count = kmp_count(text, pattern, lps, 0, 0, 0)
    IO.puts(count)
  end
  
  defp build_lps(pattern) do
    m = length(pattern)
    lps = List.duplicate(0, m)
    build_lps_helper(pattern, lps, 1, 0)
  end
  
  defp build_lps_helper(pattern, lps, i, len) when i >= length(pattern) do
    lps
  end
  
  defp build_lps_helper(pattern, lps, i, len) do
    if Enum.at(pattern, i) == Enum.at(pattern, len) do
      new_len = len + 1
      new_lps = List.replace_at(lps, i, new_len)
      build_lps_helper(pattern, new_lps, i + 1, new_len)
    else
      if len != 0 do
        build_lps_helper(pattern, lps, i, Enum.at(lps, len - 1))
      else
        new_lps = List.replace_at(lps, i, 0)
        build_lps_helper(pattern, new_lps, i + 1, 0)
      end
    end
  end
  
  defp kmp_count(text, pattern, lps, i, j, count) when i >= length(text) do
    count
  end
  
  defp kmp_count(text, pattern, lps, i, j, count) do
    if Enum.at(text, i) == Enum.at(pattern, j) do
      new_i = i + 1
      new_j = j + 1
      if new_j >= length(pattern) do
        new_count = count + 1
        new_j = if j > 0, do: Enum.at(lps, j - 1), else: 0
        kmp_count(text, pattern, lps, new_i, new_j, new_count)
      else
        kmp_count(text, pattern, lps, new_i, new_j, count)
      end
    else
      if j != 0 do
        new_j = Enum.at(lps, j - 1)
        kmp_count(text, pattern, lps, i, new_j, count)
      else
        kmp_count(text, pattern, lps, i + 1, 0, count)
      end
    end
  end

  def main() do
    args = System.argv()
    
    if length(args) < 2 do
      IO.puts(:stderr, "usage: multi.exs <task> <args...>")
      System.halt(1)
    end
    
    [task | rest] = args
    
    case task do
      "sieve_primes" ->
        n = String.to_integer(Enum.at(rest, 0))
        sieve_primes(n)
      
      "sort_ints" ->
        n = String.to_integer(Enum.at(rest, 0))
        sort_ints(n)
      
      "matmul_f64" ->
        n = String.to_integer(Enum.at(rest, 0))
        matmul(n)
      
      "string_kmp" ->
        if length(rest) < 2 do
          IO.puts(:stderr, "need N M")
          System.halt(1)
        end
        n = String.to_integer(Enum.at(rest, 0))
        m = String.to_integer(Enum.at(rest, 1))
        kmp_search(n, m)
      
      _ ->
        IO.puts(:stderr, "unknown task: #{task}")
        System.halt(1)
    end
  end
end

Multi.main()