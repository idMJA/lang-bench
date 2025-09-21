defmodule ElixirMulti do
  @seed 123_456_789

  # LCG implementation with state passed around
  def lcg_next(s) do
    new_s = rem(1_664_525 * s + 1_013_904_223, 4_294_967_296)
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
          Stream.iterate(p * p, &(&1 + p))
          |> Stream.take_while(&(&1 <= n))
          |> Enum.each(fn m -> :ets.insert(comp, {m, true}) end)

        _ ->
          :ok
      end
    end

    count =
      Enum.count(2..n, fn i ->
        case :ets.lookup(comp, i) do
          [] -> true
          _ -> false
        end
      end)

    :ets.delete(comp)
    IO.puts(count)
  end

  def sort_ints(n) do
    {arr, _} =
      Enum.map_reduce(1..n, @seed, fn _, s ->
        {new_s, val} = lcg_next(s)
        {val, new_s}
      end)

    sorted = Enum.sort(arr)

    xorv =
      Enum.at(sorted, 0)
      |> Bitwise.bxor(Enum.at(sorted, div(n, 2)))
      |> Bitwise.bxor(Enum.at(sorted, n - 1))

    xorv = Bitwise.band(xorv, 0xFFFFFFFF)
    total = Enum.reduce(sorted, 0, fn x, acc -> Bitwise.band(acc + x, 0xFFFFFFFFFFFFFFFF) end)
    IO.puts("#{xorv} #{total}")
  end

  def matmul(n) do
    {a_vals, last_s} =
      Enum.map_reduce(1..(n * n), @seed, fn _, s ->
        {new_s, val} = lcg_next(s)
        {val / 4_294_967_296.0, new_s}
      end)

    {b_vals, _} =
      Enum.map_reduce(1..(n * n), last_s, fn _, s ->
        {new_s, val} = lcg_next(s)
        {val / 4_294_967_296.0, new_s}
      end)

    a_matrix = Enum.chunk_every(a_vals, n)
    b_matrix = Enum.chunk_every(b_vals, n)

    c_matrix =
      for i <- 0..(n - 1) do
        for j <- 0..(n - 1) do
          Enum.reduce(0..(n - 1), 0.0, fn k, acc ->
            acc + Enum.at(Enum.at(a_matrix, i), k) * Enum.at(Enum.at(b_matrix, k), j)
          end)
        end
      end

    sum = c_matrix |> List.flatten() |> Enum.sum()
    <<bits::64>> = <<sum::float>>
    IO.puts(:io_lib.format("~16.16.0b", [bits]) |> List.to_string())
  end

  def kmp_search(n, m) do
    # Build binaries for text and pattern to use efficient BEAM binary search
    {text_chunks, last_s} =
      Enum.map_reduce(1..n, @seed, fn _, s ->
        {new_s, val} = lcg_next(s)
        {<<(?a + rem(val, 26))>>, new_s}
      end)

    {pattern_chunks, _} =
      Enum.map_reduce(1..m, last_s, fn _, s ->
        {new_s, val} = lcg_next(s)
        {<<(?a + rem(val, 26))>>, new_s}
      end)

    text_bin = IO.iodata_to_binary(text_chunks)
    pattern_bin = IO.iodata_to_binary(pattern_chunks)

    # Use :binary.matches/2 implemented efficiently in the VM
    matches = :binary.matches(text_bin, pattern_bin)
    IO.puts(length(matches))
  end


  def main(args) do
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
