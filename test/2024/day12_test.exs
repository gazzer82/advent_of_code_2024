defmodule Aoc2024.Solutions.Y24.Day12Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day12, as: Solution, warn: false
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
    RRRRIICCFF
    RRRRIICCCF
    VVRRRCCFFF
    VVRCCCJFFF
    VVVVCJJCFE
    VVIVCCJJEE
    VVIIICJJEE
    MIIIIIJJEE
    MIIISIJEEE
    MMMISSJEEE
    """

    assert 1930 == solve(input, :part_one)
  end

  @part_one_solution 1_457_298

  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2024, 12, :part_one)
  end

  test "part two example" do
    input = ~S"""
    AAAAAA
    AAABBA
    AAABBA
    ABBAAA
    ABBAAA
    AAAAAA
    """

    assert 368 == solve(input, :part_two)
  end

  @part_two_solution 921_636

  test "part two solution" do
    assert {:ok, @part_two_solution} == AoC.run(2024, 12, :part_two)
  end
end
