#!/usr/bin/env elixir

defmodule Multi do
  import Bitwise

  def lcg_next(seed) do
    ((seed * 1664525) + 1013904223) &&& 0xFFFFFFFF
  end

  def sieve_primes(n) when n < 2 do
    IO.puts(0)
  end

  def sieve_primes(n) do
    comp = :array.new(n + 1, default: false)
    comp = :array.set(0, true, comp)
    comp = :array.set(1, true, comp)
    
    lim = trunc(:math.sqrt(n))
    comp = mark_composites(comp, 2, lim, n)
    
    count = count_primes(comp, 2, n, 0)
    IO.puts(count)
  end

  defp mark_composites(comp, p, lim, n) when p > lim, do: comp
  defp mark_composites(comp, p, lim, n) do
    comp = if not :array.get(p, comp) do
      mark_multiples(comp, p * p, p, n)
    else
      comp
    end
    mark_composites(comp, p + 1, lim, n)
  end

  defp mark_multiples(comp, m, p, n) when m > n, do: comp
  defp mark_multiples(comp, m, p, n) do
    comp = :array.set(m, true, comp)
    mark_multiples(comp, m + p, p, n)
  end

  defp count_primes(comp, i, n, acc) when i > n, do: acc
  defp count_primes(comp, i, n, acc) do
    acc = if not :array.get(i, comp), do: acc + 1, else: acc
    count_primes(comp, i + 1, n, acc)
  end

  def sort_ints(n) do
    {a, _} = generate_array(n, 123456789, [])
    sorted = Enum.sort(a)
    xorv = (Enum.at(sorted, 0) ^^^ Enum.at(sorted, div(n, 2)) ^^^ Enum.at(sorted, n - 1)) &&& 0xFFFFFFFF
    total = Enum.reduce(sorted, 0, fn x, acc -> (acc + (x &&& 0xFFFFFFFF)) &&& 0xFFFFFFFFFFFFFFFF end)
    IO.puts("#{xorv} #{total}")
  end

  defp generate_array(0, _seed, acc), do: {Enum.reverse(acc), _seed}
  defp generate_array(n, seed, acc) do
    new_seed = lcg_next(seed)
    generate_array(n - 1, new_seed, [new_seed | acc])
  end

  def matmul(n) do
    inv = 1.0 / 4294967296.0
    {a, seed2} = generate_float_array(n * n, 123456789, [], inv)
    {b, _} = generate_float_array(n * n, seed2, [], inv)
    
    c = multiply_matrices(a, b, n)
    sum = Enum.sum(c)
    
    <<bits::64>> = <<sum::float>>
    IO.puts(:io_lib.format("~16.16.0b", [bits]))
  end

  defp generate_float_array(0, seed, acc, _inv), do: {Enum.reverse(acc), seed}
  defp generate_float_array(n, seed, acc, inv) do
    new_seed = lcg_next(seed)
    val = new_seed * inv
    generate_float_array(n - 1, new_seed, [val | acc])
  end

  defp multiply_matrices(a, b, n) do
    c = List.duplicate(0.0, n * n)
    multiply_rows(a, b, c, n, 0)
  end

  defp multiply_rows(_a, _b, c, n, i) when i >= n, do: c
  defp multiply_rows(a, b, c, n, i) do
    c = multiply_cols(a, b, c, n, i, 0)
    multiply_rows(a, b, c, n, i + 1)
  end

  defp multiply_cols(_a, _b, c, n, _i, k) when k >= n, do: c
  defp multiply_cols(a, b, c, n, i, k) do
    aik = Enum.at(a, i * n + k)
    c = multiply_inner(b, c, n, i, k, aik, 0)
    multiply_cols(a, b, c, n, i, k + 1)
  end

  defp multiply_inner(_b, c, n, _i, _k, _aik, j) when j >= n, do: c
  defp multiply_inner(b, c, n, i, k, aik, j) do
    bij = Enum.at(b, k * n + j)
    old_val = Enum.at(c, i * n + j)
    new_val = old_val + aik * bij
    c = List.replace_at(c, i * n + j, new_val)
    multiply_inner(b, c, n, i, k, aik, j + 1)
  end

  def kmp(n, m) do
    {t, seed2} = generate_text(n, 123456789, [])
    {p, _} = generate_text(m, seed2, [])
    
    lps = compute_lps(p, m)
    count = find_matches(t, p, n, m, lps, 0, 0, 0)
    IO.puts(count)
  end

  defp generate_text(0, seed, acc), do: {Enum.reverse(acc), seed}
  defp generate_text(n, seed, acc) do
    new_seed = lcg_next(seed)
    char = 97 + rem(new_seed, 26)
    generate_text(n - 1, new_seed, [char | acc])
  end

  defp compute_lps(p, m) do
    lps = :array.new(m, default: 0)
    compute_lps_loop(p, lps, 1, 0, m)
  end

  defp compute_lps_loop(_p, lps, i, _len, m) when i >= m, do: lps
  defp compute_lps_loop(p, lps, i, len, m) do
    if Enum.at(p, i) == Enum.at(p, len) do
      len = len + 1
      lps = :array.set(i, len, lps)
      compute_lps_loop(p, lps, i + 1, len, m)
    else
      if len != 0 do
        len = :array.get(len - 1, lps)
        compute_lps_loop(p, lps, i, len, m)
      else
        lps = :array.set(i, 0, lps)
        compute_lps_loop(p, lps, i + 1, len, m)
      end
    end
  end

  defp find_matches(_t, _p, n, _m, _lps, i, _j, count) when i >= n, do: count
  defp find_matches(t, p, n, m, lps, i, j, count) do
    if Enum.at(t, i) == Enum.at(p, j) do
      i = i + 1
      j = j + 1
      if j == m do
        count = count + 1
        j = :array.get(j - 1, lps)
      end
      find_matches(t, p, n, m, lps, i, j, count)
    else
      if j != 0 do
        j = :array.get(j - 1, lps)
        find_matches(t, p, n, m, lps, i, j, count)
      else
        i = i + 1
        find_matches(t, p, n, m, lps, i, j, count)
      end
    end
  end

  def main(args) do
    case args do
      [task | rest] ->
        case task do
          "sieve_primes" ->
            [n_str] = rest
            n = String.to_integer(n_str)
            sieve_primes(n)
          
          "sort_ints" ->
            [n_str] = rest
            n = String.to_integer(n_str)
            sort_ints(n)
          
          "matmul_f64" ->
            [n_str] = rest
            n = String.to_integer(n_str)
            matmul(n)
          
          "string_kmp" ->
            [n_str, m_str] = rest
            n = String.to_integer(n_str)
            m = String.to_integer(m_str)
            kmp(n, m)
          
          _ ->
            IO.puts(:stderr, "unknown task: #{task}")
            System.halt(1)
        end
      
      [] ->
        IO.puts(:stderr, "usage: multi.exs <task> <args...>")
        System.halt(1)
    end
  end
end

Multi.main(System.argv())