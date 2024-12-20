defmodule Aoc2024.Solutions.Y24.Day19 do
  alias AoC.Input

  def parse(input, _part) do
    [towels, patterns] = Input.read!(input) |> String.split("\n\n", trim: true)
    towels = towels |> String.split(", ", trim: true)
    patterns = patterns |> String.split("\n", trim: true)
    {towels, patterns}
  end

  def part_one({towels, patterns}) do
    # towels = Enum.sort_by(towels, &String.length/1, :desc)

    Task.async_stream(
      patterns,
      fn pattern ->
        Process.put(:memo, %{})
        result = match_patterns(towels, pattern, towels)
        Process.delete(:memo)
        result
      end,
      ordered: false,
      max_concurrency: System.schedulers_online() * 2
    )
    |> Enum.filter(& &1)
    |> Enum.count(& &1)

    # Enum.map(patterns, &match_patterns(towels, &1, towels))
    # |> Enum.filter(& &1)
    # |> Enum.count(& &1)
  end

  def match_patterns(_, "", _towels), do: true

  def match_patterns([], _pattern, _towels), do: false

  def match_patterns([towel | rest], pattern, towels) do
    cache_key = {towel, pattern}

    case Process.get(:memo) |> Map.get(cache_key) do
      nil ->
        result =
          case String.starts_with?(pattern, towel) do
            true ->
              if match_patterns(towels, String.replace(pattern, towel, "", global: false), towels) do
                true
              else
                match_patterns(rest, pattern, towels)
              end

            _ ->
              match_patterns(rest, pattern, towels)
          end

        Process.put(:memo, Map.put(Process.get(:memo), cache_key, result))
        result

      cached_result ->
        cached_result
    end
  end

  def part_two({towels, patterns}) do
    towels = Enum.sort_by(towels, &String.length/1, :desc)

    Task.async_stream(
      patterns,
      fn pattern ->
        Process.put(:memo, %{})
        result = count_all_matches(towels, pattern, towels)
        Process.delete(:memo)
        result
      end,
      ordered: false,
      max_concurrency: System.schedulers_online() * 2
    )
    |> Enum.reduce(0, fn {:ok, count}, acc -> acc + count end)
  end

  def count_all_matches(_, "", _towels), do: 1
  def count_all_matches([], _pattern, _towels), do: 0

  def count_all_matches([towel | rest], pattern, towels) do
    cache_key = {towel, pattern}

    case Process.get(:memo) |> Map.get(cache_key) do
      nil ->
        result =
          case String.starts_with?(pattern, towel) do
            true ->
              remaining = String.slice(pattern, String.length(towel)..-1//1)

              count_all_matches(towels, remaining, towels) +
                count_all_matches(rest, pattern, towels)

            _ ->
              count_all_matches(rest, pattern, towels)
          end

        Process.put(:memo, Map.put(Process.get(:memo), cache_key, result))
        result

      cached_result ->
        cached_result
    end
  end
end
