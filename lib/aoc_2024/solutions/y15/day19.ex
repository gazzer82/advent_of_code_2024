defmodule Aoc2024.Solutions.Y15.Day19 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input) |> String.split("\n", trim: true)
  end

  def part_one(problem) do
    input = List.last(problem)

    keys =
      List.delete_at(problem, -1)
      |> Enum.reduce(%{}, fn key, acc ->
        [key, value] = String.split(key, " => ")
        current = Map.get(acc, key, [])
        Map.put(acc, key, current ++ [value])
      end)

    Map.to_list(keys)

    find_replacements(keys, input)
    |> List.flatten()
    |> Enum.uniq_by(fn result ->
      result
    end)
    |> length()
  end

  def find_replacements(keys, input) do
    # IO.inspect(keys)

    Enum.map(keys, fn {key, values} ->
      regex = ~r/#{key}/

      # indexes =
      Regex.scan(regex, input, return: :index)
      |> List.flatten()
      |> Enum.map(fn {index, length} ->
        {b, e} = String.split_at(input, index + length)

        b =
          case String.length(b) do
            0 -> ""
            _ -> String.slice(b, 0, String.length(b) - length)
          end

        Enum.reduce(values, [], fn rep, acc ->
          acc ++ ["#{b}#{rep}#{e}"]
        end)
      end)
    end)
  end

  # def part_two(problem) do
  #   problem
  # end
end
