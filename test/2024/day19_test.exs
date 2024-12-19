defmodule Aoc2024.Solutions.Y24.Day19Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day19, as: Solution, warn: false
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
    r, wr, b, g, bwu, rb, gb, br

    brwrr
    bggr
    gbbr
    rrbgbr
    ubwu
    bwurrg
    brgr
    bbrgwb
    """

    assert 6 == solve(input, :part_one)
  end

  @part_one_solution 228

  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2024, 19, :part_one)
  end

  test "part two example" do
    input = ~S"""
    r, wr, b, g, bwu, rb, gb, br

    brwrr
    bggr
    gbbr
    rrbgbr
    ubwu
    bwurrg
    brgr
    bbrgwb
    """

    assert 16 == solve(input, :part_two)
  end

  # @part_two_solution CHANGE_ME
  #
  # test "part two solution" do
  #   assert {:ok, @part_two_solution} == AoC.run(2024, 19, :part_two)
  # end
end
