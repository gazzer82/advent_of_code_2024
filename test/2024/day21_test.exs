defmodule Aoc2024.Solutions.Y24.Day21Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day21, as: Solution, warn: false
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
    029A
    980A
    179A
    456A
    379A
    """

    assert 126_384 == solve(input, :part_one)
  end

  @part_one_solution 162_740

  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2024, 21, :part_one)
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

  @part_two_solution 203_640_915_832_208

  test "part two solution" do
    assert {:ok, @part_two_solution} == AoC.run(2024, 21, :part_two)
  end
end
