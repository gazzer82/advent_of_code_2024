defmodule Aoc2024.Solutions.Y24.Day22 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input) |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1)
  end

  def part_one(problem) do
    problem
    |> Enum.map(&generate_secret(&1, 2000, 0))
    |> Enum.sum()
  end

  def generate_secret(secret, target, current) when target == current do
    secret
  end

  def generate_secret(secret, target, current) do
    mul1_secret = (secret * 64) |> process(secret)
    div_secret = (mul1_secret / 32) |> floor() |> process(mul1_secret)
    mul2_secret = (div_secret * 2048) |> process(div_secret)

    generate_secret(mul2_secret, target, current + 1)
  end

  def process(new_secret, secret) do
    mix(new_secret, secret)
    |> prune()
  end

  def mix(new_secret, secret) do
    Bitwise.bxor(secret, new_secret)
  end

  def prune(new_secret) do
    Integer.mod(new_secret, 16_777_216)
  end

  def part_two(problem) do
    {_, result} =
      problem
      |> split_into_chunks()
      |> Task.async_stream(fn parts ->
        Enum.map(parts, &generate_sell_sequence(&1, 2000, 0, [], 0))
      end)
      |> merge_results_stream()
      |> Enum.map(&generate_and_score_unique_sequence(&1))
      |> Enum.reduce(fn prev, curr ->
        Map.merge(prev, curr, fn _k, v1, v2 -> v1 + v2 end)
      end)
      |> Enum.max_by(fn {_key, value} -> value end)

    result
  end

  def generate_and_score_unique_sequence(sequence) do
    Enum.drop(sequence, 1)
    |> Enum.chunk_every(4, 1, :discard)
    |> Enum.reduce(%{}, fn [{_, one}, {_, two}, {_, three}, {sell, four}], acc ->
      Map.put_new(acc, {one, two, three, four}, sell)
    end)
  end

  def collect_other_seq_parts(sequnce, seq_part, idx) do
    [Enum.at(sequnce, idx - 3), Enum.at(sequnce, idx - 2), Enum.at(sequnce, idx - 1), seq_part]
    |> Enum.map(fn {_sell, seq} -> seq end)
  end

  def generate_sell_sequence(_secret, target, current, acc, _) when target == current do
    acc
  end

  def generate_sell_sequence(secret, target, current, acc, _last_digit_previous)
      when current == 0 do
    last_digit = secret |> Integer.digits() |> List.last()
    generate_sell_sequence(secret, target, current + 1, acc ++ [{last_digit, :null}], last_digit)
  end

  def generate_sell_sequence(secret, target, current, acc, last_digit_previous) do
    mul1_secret = (secret * 64) |> process(secret)
    div_secret = (mul1_secret / 32) |> floor() |> process(mul1_secret)
    new_secret = (div_secret * 2048) |> process(div_secret)
    last_digit = new_secret |> Integer.digits() |> List.last()
    diff = last_digit - last_digit_previous

    generate_sell_sequence(
      new_secret,
      target,
      current + 1,
      acc ++ [{last_digit, diff}],
      last_digit
    )
  end

  defp split_into_chunks(options) do
    workers = :erlang.system_info(:schedulers_online)
    options_count = Enum.count(options)
    options_per_chunk = :erlang.ceil(options_count / workers)

    Enum.chunk_every(options, options_per_chunk)
  end

  defp merge_results_stream(results_stream) do
    Enum.reduce(results_stream, [], fn {:ok, worker_result}, acc ->
      acc ++ worker_result
    end)
  end
end
