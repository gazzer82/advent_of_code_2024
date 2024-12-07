defmodule Aoc2024.Solutions.Y24.Day07 do
  alias AoC.Input

  alias Aoc2024.Solutions.Y24.Day07.Parser

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(fn ip ->
      {:ok, [total | options], "", _, _, _} = Parser.parse_line(ip)
      {total, options}
    end)
  end

  def part_one(problem) do
    do_work_backwards(problem, :part_one)
  end

  def part_two(problem) do
    do_work_backwards(problem, :part_two)
  end

  def do_work_backwards(problem, part) do
    problem
    |> split_into_chunks()
    |> Task.async_stream(fn options ->
      do_calculations_backwards(options, part)
    end)
    |> Stream.flat_map(fn {:ok, result} -> result end)
    |> Stream.filter(fn {_total, valid} ->
      valid
    end)
    |> Stream.map(fn {total, _} -> total end)
    |> Enum.sum()
  end

  def do_calculations_backwards(problem, part) do
    problem
    |> Enum.map(fn {total, options} ->
      {total, do_calculation_backwards(total, options |> Enum.reverse(), total, part)}
    end)
  end

  def do_calculation_backwards(_total, [option | []], current, _part), do: current == option

  def do_calculation_backwards(_total, [], current, _part), do: current == 0

  def do_calculation_backwards(total, [option | rest], current, :part_one = part) do
    sub_valid = current - option > 0
    div_valid = rem(current, option) == 0 && current / option > 0

    cond do
      sub_valid && div_valid ->
        do_calculation_backwards(total, rest, current - option, part) ||
          do_calculation_backwards(total, rest, trunc(current / option), part)

      sub_valid ->
        do_calculation_backwards(total, rest, current - option, part)

      div_valid ->
        do_calculation_backwards(total, rest, trunc(current / option), part)

      true ->
        false
    end
  end

  def do_calculation_backwards(total, [option | rest], current, :part_two = part) do
    sub_valid = current - option > 0
    div_valid = rem(current, option) == 0 && current / option > 0
    current_str = Integer.to_string(current)
    option_str = Integer.to_string(option)
    concat_valid = String.ends_with?(current_str, option_str)

    cond do
      sub_valid && div_valid && concat_valid ->
        do_calculation_backwards(total, rest, current - option, part) ||
          do_calculation_backwards(total, rest, trunc(current / option), part) ||
          do_calculation_backwards(total, rest, reverse_concat_calculation(current, option), part)

      sub_valid && concat_valid ->
        do_calculation_backwards(total, rest, current - option, part) ||
          do_calculation_backwards(total, rest, reverse_concat_calculation(current, option), part)

      div_valid && concat_valid ->
        do_calculation_backwards(total, rest, trunc(current / option), part) ||
          do_calculation_backwards(total, rest, reverse_concat_calculation(current, option), part)

      sub_valid && div_valid ->
        do_calculation_backwards(total, rest, current - option, part) ||
          do_calculation_backwards(total, rest, trunc(current / option), part)

      concat_valid ->
        do_calculation_backwards(total, rest, reverse_concat_calculation(current, option), part)

      sub_valid ->
        do_calculation_backwards(total, rest, current - option, part)

      div_valid ->
        do_calculation_backwards(total, rest, trunc(current / option), part)

      true ->
        false
    end
  end

  def do_work(problem, part) do
    problem
    |> split_into_chunks()
    |> Task.async_stream(fn options ->
      do_calculations(options, part)
    end)
    |> Stream.flat_map(fn {:ok, result} -> result end)
    |> Stream.filter(fn {_total, valid} ->
      valid
    end)
    |> Stream.map(fn {total, _} -> total end)
    |> Enum.sum()
  end

  def do_calculations(problem, part) do
    problem
    |> Enum.map(fn {total, [current | rest]} ->
      {total, do_calculation(total, rest, current, part)}
    end)
  end

  def do_calculation(total, _, current, _part) when current > total, do: false

  def do_calculation(total, [], current, _part), do: current == total

  def do_calculation(total, [option | rest], current, part) do
    case part do
      :part_one ->
        with false <- do_calculation(total, rest, current * option, part),
             false <- do_calculation(total, rest, current + option, part) do
          false
        else
          _ -> true
        end

      :part_two ->
        with false <- do_calculation(total, rest, current * option, part),
             false <- do_calculation(total, rest, current + option, part),
             false <- do_calculation(total, rest, get_concat_calculation(current, option), part) do
          false
        else
          _ -> true
        end
    end
  end

  defp get_concat_calculation(a, b) when b < 10, do: a * 10 + b
  defp get_concat_calculation(a, b) when b < 100, do: a * 100 + b
  defp get_concat_calculation(a, b) when b < 1000, do: a * 1000 + b

  defp reverse_concat_calculation(a, b) when b < 10, do: floor((a - b) / 10)
  defp reverse_concat_calculation(a, b) when b < 100, do: floor((a - b) / 100)
  defp reverse_concat_calculation(a, b) when b < 1000, do: floor((a - b) / 1000)

  defp split_into_chunks(options) do
    workers = :erlang.system_info(:schedulers_online)
    options_count = Enum.count(options)
    options_per_chunk = :erlang.ceil(options_count / workers)

    Enum.chunk_every(options, options_per_chunk)
  end
end
