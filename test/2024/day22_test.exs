defmodule Aoc2024.Solutions.Y24.Day22Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day22, as: Solution, warn: false
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
    1
    10
    100
    2024
    """

    assert 37_327_623 == solve(input, :part_one)
  end

  @part_one_solution 13_753_970_725

  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2024, 22, :part_one)
  end

  test "part two example" do
    input = ~S"""
    1
    2
    3
    2024
    """

    assert 23 == solve(input, :part_two)
  end

  # @part_two_solution CHANGE_ME
  #
  # test "part two solution" do
  #   assert {:ok, @part_two_solution} == AoC.run(2024, 22, :part_two)
  # end
end
