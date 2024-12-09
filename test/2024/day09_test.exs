defmodule Aoc2024.Solutions.Y24.Day09Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day09, as: Solution, warn: false
  use ExUnit.Case, async: true

  defp solve(input, part) do
    problem =
      input
      |> Input.as_file()
      |> Solution.parse(part)

    apply(Solution, part, [problem])
  end

  test "part one example" do
    input = ~S"""
    2333133121414131402
    """

    assert 1928 == solve(input, :part_one)
  end

  @part_one_solution 6_200_294_120_911

  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2024, 9, :part_one)
  end

  test "part two example" do
    input = ~S"""
    23331331214141314020
    """

    assert 2858 == solve(input, :part_two)
  end

  @part_two_solution 6_227_018_762_750

  test "part two solution" do
    assert {:ok, @part_two_solution} == AoC.run(2024, 9, :part_two)
  end
end
