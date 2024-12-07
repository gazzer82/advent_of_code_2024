defmodule Aoc2024.Solutions.Y24.Day07 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(fn ip ->
      [total | options] = String.split(ip, " ")
      [total | _] = String.split(total, ":")
      {total |> String.to_integer(), options |> Enum.map(&String.to_integer/1)}
    end)
  end

  def part_one(problem) do
    problem
    |> do_calculations()
    |> Enum.filter(fn {_total, valid} ->
      valid
    end)
    |> Enum.reduce(0, fn {total, _}, acc ->
      acc + total
    end)
  end

  def do_calculations(problem) do
    problem
    |> Enum.map(fn {total, [current | rest]} ->
      {total, do_calculation(total, rest, current)}
    end)
  end

  def do_calculation(total, [], current) do
    [current == total]
  end

  def do_calculation(total, [option | rest], current) do
    multi_valid = check_multi_calculation(total, option, current)
    add_valid = check_plus_calculation(total, option, current)

    cond do
      multi_valid and add_valid ->
        [
          do_calculation(total, rest, current * option),
          do_calculation(total, rest, current + option)
        ]
        |> List.flatten()
        |> Enum.filter(& &1)
        |> List.first(false)

      multi_valid ->
        [do_calculation(total, rest, current * option)]
        |> List.flatten()
        |> Enum.filter(& &1)
        |> List.first(false)

      add_valid ->
        [do_calculation(total, rest, current + option)]
        |> List.flatten()
        |> Enum.filter(& &1)
        |> List.first(false)

      true ->
        false
    end
  end

  def check_multi_calculation(total, option, current)
      when option * current <= total do
    true
  end

  def check_multi_calculation(_total, _options, _current), do: false

  def check_plus_calculation(total, option, current)
      when option + current <= total do
    true
  end

  def check_plus_calculation(_total, _options, _current), do: false

  def check_concat_calculation(total, option, current) do
    concat_number = current * trunc(:math.pow(10, trunc(:math.log10(option)) + 1)) + option

    if concat_number <= total do
      {true, concat_number}
    else
      {false, 0}
    end
  end

  def part_two(problem) do
    problem
    |> do_calculations_part_2()
    |> Enum.filter(fn {_total, valid} ->
      valid
    end)
    |> Enum.reduce(0, fn {total, _}, acc ->
      acc + total
    end)
  end

  def do_calculations_part_2(problem) do
    problem
    |> Enum.map(fn {total, [current | rest]} ->
      {total, do_calculation_part_2(total, rest, current)}
    end)
  end

  def do_calculation_part_2(total, [], current) do
    [current == total]
  end

  def do_calculation_part_2(total, [option | rest], current) do
    multi_valid = check_multi_calculation(total, option, current)
    add_valid = check_plus_calculation(total, option, current)
    {concat_valid, concat_value} = check_concat_calculation(total, option, current)

    cond do
      multi_valid and add_valid and concat_valid ->
        [
          do_calculation_part_2(total, rest, current * option),
          do_calculation_part_2(total, rest, current + option),
          do_calculation_part_2(total, rest, concat_value)
        ]
        |> List.flatten()
        |> Enum.filter(& &1)
        |> List.first(false)

      multi_valid and concat_valid ->
        [
          do_calculation_part_2(total, rest, current * option),
          do_calculation_part_2(total, rest, concat_value)
        ]
        |> List.flatten()
        |> Enum.filter(& &1)
        |> List.first(false)

      multi_valid and add_valid ->
        [
          do_calculation_part_2(total, rest, current * option),
          do_calculation_part_2(total, rest, current + option)
        ]
        |> List.flatten()
        |> Enum.filter(& &1)
        |> List.first(false)

      add_valid and concat_valid ->
        [
          do_calculation_part_2(total, rest, current + option),
          do_calculation_part_2(total, rest, concat_value)
        ]
        |> List.flatten()
        |> Enum.filter(& &1)
        |> List.first(false)

      multi_valid ->
        [do_calculation_part_2(total, rest, current * option)]
        |> List.flatten()
        |> Enum.filter(& &1)
        |> List.first(false)

      add_valid ->
        [do_calculation_part_2(total, rest, current + option)]
        |> List.flatten()
        |> Enum.filter(& &1)
        |> List.first(false)

      concat_valid ->
        [do_calculation_part_2(total, rest, concat_value)]
        |> List.flatten()
        |> Enum.filter(& &1)
        |> List.first(false)

      true ->
        false
    end
  end
end
