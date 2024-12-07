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
    do_work(problem, :part_one)
  end

  def part_two(problem) do
    do_work(problem, :part_two)
  end

  def do_work(problem, part) do
    problem
    |> split_into_chunks()
    |> Task.async_stream(fn options ->
      do_calculations(options, part)
    end)
    |> merge_results_stream()
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

  # def get_concat_calculation(option, current) do
  #   current * trunc(:math.pow(10, trunc(:math.log10(option)) + 1)) + option
  # end

  defp get_concat_calculation(a, b) when b < 10, do: a * 10 + b
  defp get_concat_calculation(a, b) when b < 100, do: a * 100 + b
  defp get_concat_calculation(a, b) when b < 1000, do: a * 1000 + b

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
