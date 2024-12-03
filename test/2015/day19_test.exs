defmodule Aoc2024.Solutions.Y15.Day19Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y15.Day19, as: Solution, warn: false
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
    H => HO
    H => OH
    O => HH

    HOHOHO
    """

    assert 7 == solve(input, :part_one)
  end

  @part_one_solution 535

  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2015, 19, :part_one)
  end

  # test "part two example" do
  #   input = ~S"""
  #   This is an
  #   example input.
  #   replace with
  #   an example from
  #   the AoC website.
  #   """

  #   assert CHANGE_ME == solve(input, :part_two)
  # end

  # @part_two_solution CHANGE_ME
  #
  # test "part two solution" do
  #   assert {:ok, @part_two_solution} == AoC.run(2015, 19, :part_two)
  # end
end
