defmodule Aoc2024.Solutions.Y24.Day09 do
  alias AoC.Input

  require Integer

  alias Arrays

  def parse(input, _) do
    Input.read!(input)
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(fn step ->
      String.to_integer(step)
    end)
  end

  def part_one(problem) do
    problem
    |> build_string(:file, 0, [])
    |> replace_spaces()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {curr, idx}, acc ->
      acc + String.to_integer(curr) * idx
    end)
  end

  def build_string([], _, _idx, acc) do
    acc
  end

  def build_string([0 | tail], :file, idx, acc) do
    build_string(tail, :space, idx + 1, acc)
  end

  def build_string([head | tail], :file, idx, acc) do
    string_part = acc ++ (1..head |> Enum.map(fn _ -> "#{idx}" end))
    build_string(tail, :space, idx + 1, string_part)
  end

  def build_string([0 | tail], :space, idx, acc) do
    build_string(tail, :file, idx, acc)
  end

  def build_string([head | tail], :space, idx, acc) do
    string_part = acc ++ (1..head |> Enum.map(fn _ -> "." end))
    build_string(tail, :file, idx, string_part)
  end

  def replace_spaces(spaces) do
    case Enum.find_index(spaces, fn space ->
           space == "."
         end) do
      nil ->
        spaces

      index ->
        {rem, last} = get_last(spaces)
        replace_spaces(List.replace_at(rem, index, last))
    end
  end

  def get_last(spaces) do
    {rem, [last]} = Enum.split(spaces, length(spaces) - 1)

    if last == "." do
      get_last(rem)
    else
      {rem, last}
    end
  end

  def part_two(problem) do
    map = build_map(problem, :file, 0, 0, []) |> Enum.reverse()

    {spaces, files} =
      map
      |> Enum.chunk_by(fn {_, v} -> v end)
      |> Enum.map(fn [{_, status} | _] = list ->
        {Enum.map(list, &elem(&1, 0)), status}
      end)
      |> Enum.split_with(fn {_, id} -> id == :free end)

    spaces =
      Enum.map(spaces, fn {options, :free} ->
        {options, length(options)}
      end)

    locs = move_files(Enum.reverse(files), spaces, [])
    fuzz(locs)
  end

  defp build_map([0 | t], :file, idx, file, acc) do
    build_map(t, :free, idx, file + 1, acc)
  end

  defp build_map([0 | t], :free, idx, file, acc) do
    build_map(t, :file, idx, file, acc)
  end

  defp build_map([h | t], :file, idx, file, acc) do
    build_map([h - 1 | t], :file, idx + 1, file, [{idx, file} | acc])
  end

  defp build_map([h | t], :free, idx, file, acc) do
    build_map([h - 1 | t], :free, idx + 1, file, [{idx, :free} | acc])
  end

  defp build_map([], _, _, _, acc), do: acc

  defp move_files(
         [{[low_bid | _] = options, file} = h | rev_files],
         [{[high_free | _], _} | _] = spaces,
         acc
       )
       when high_free < low_bid do
    space = take_space(spaces, options)
    [bid | _] = options

    case space do
      {[free_bid | _] = free_options, spaces} when free_bid < bid ->
        move_files(rev_files, spaces, [{free_options, file} | acc])

      _ ->
        move_files(rev_files, spaces, [h | acc])
    end
  end

  defp move_files(rest, _, acc), do: rest ++ acc

  defp fuzz(locs) do
    Enum.reduce(locs, 0, fn {options, f}, acc when is_integer(f) ->
      Enum.reduce(options, acc, fn b, acc -> acc + b * f end)
    end)
  end

  defp take_space(spaces, options) do
    take_space(spaces, length(options), [])
  end

  defp take_space([{vids, larger_len} | rest], len, skipped) when len < larger_len do
    {vids_used, vids_rest} = Enum.split(vids, len)
    {vids_used, :lists.reverse(skipped, [{vids_rest, larger_len - len} | rest])}
  end

  defp take_space([{vids, same_len} | rest], same_len, skipped) do
    {vids, :lists.reverse(skipped, rest)}
  end

  defp take_space([skip | rest], len, skipped) do
    take_space(rest, len, [skip | skipped])
  end

  defp take_space([], _, _), do: nil
end
