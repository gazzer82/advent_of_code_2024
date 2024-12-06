defmodule Aoc2024.Solutions.Y24.Day05 do
  alias AoC.Input

  def parse(input, _part) do
    [pors | [updates]] =
      Input.read!(input)
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    {pors, updates}
  end

  def part_one(problem) do
    {pors, updates} = problem

    {valid, _invalid} = find_valid_invalid(updates, pors)
    find_middle_values(valid)
  end

  def find_valid_invalid(updates, pors) do
    pors =
      pors
      |> build_pors_map()

    Enum.map(updates, &(String.split(&1, ",", trim: true) |> Enum.reverse()))
    |> find_valid(pors)
    |> Enum.split_with(fn {_update, valid} ->
      valid
    end)
  end

  def find_middle_values(updates) do
    Enum.reduce(updates, 0, fn {update, _}, acc ->
      middle = ceil(div(length(update), 2))
      String.to_integer(Enum.at(update, middle)) + acc
    end)
  end

  def find_valid(updates, pors) do
    Enum.map(updates, fn update ->
      {update, check_order(update, pors)}
    end)
  end

  def check_order([], _pors), do: true

  def check_order([current_page | rest], pors) do
    case Map.fetch(pors, current_page) do
      {:ok, values} ->
        case Enum.any?(values, fn value -> value in rest end) do
          true ->
            false

          false ->
            check_order(rest, pors)
        end

      :error ->
        check_order(rest, pors)
    end
  end

  def build_pors_map(pors) do
    Enum.reduce(pors, %{}, fn por, acc ->
      [por_id, por_value] = String.split(por, "|")
      Map.put(acc, por_id, Map.get(acc, por_id, []) ++ [por_value])
    end)
  end

  def part_two(problem) do
    {pors, updates} = problem
    {_valid, updates} = find_valid_invalid(updates, pors)

    pors =
      pors
      |> Enum.map(fn por ->
        [a, b] = String.split(por, "|", trim: true)
        {a, b}
      end)

    updates =
      updates
      |> Enum.map(fn {update, _} ->
        Enum.with_index(update)
      end)

    updates = fix_updates(pors, updates)

    fix_updates(pors, updates)
    |> Enum.reduce(0, fn update, acc ->
      middle = ceil(div(length(update), 2))
      {middle_number, __index} = Enum.at(update, middle)
      String.to_integer(middle_number) + acc
    end)
  end

  def fix_updates(pors, updates) do
    Enum.map(updates, fn update ->
      fix_update(pors, update)
    end)
  end

  def fix_update([], update), do: update

  def fix_update([{index_page, following_page} | rest], update) do
    effected_page =
      Enum.filter(update, fn {page, _index} ->
        page == index_page
      end)
      |> List.last()

    if effected_page do
      updated_update = do_swaps(update, effected_page, following_page)
      fix_update(rest, updated_update)
    else
      fix_update(rest, update)
    end
  end

  def do_swaps(update, {_number, index}, following_page) do
    {pre, post} = Enum.split(update, index + 1)

    {move, keep} =
      Enum.split_with(pre, fn {page, _index} -> page == following_page end)

    (keep ++ move ++ post) |> reset_index()
  end

  def reset_index(update) do
    Enum.map(update, fn {page, _index} ->
      page
    end)
    |> Enum.with_index()
  end
end
