defmodule Aoc2024.Solutions.Y24.Day04Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day04, as: Solution, warn: false
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
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """

    assert 18 == solve(input, :part_one)
  end

  @part_one_solution 2370

  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2024, 4, :part_one)
  end

  test "part two example" do
    input = ~S"""
    .M.S......
    ..A..MSMS.
    .M.S.MAA..
    ..A.ASMSM.
    .M.S.M....
    ..........
    S.S.S.S.S.
    .A.A.A.A..
    M.M.M.M.M.
    ..........
    """

    assert 9 == solve(input, :part_two)
  end

  @part_two_solution 1908

  test "part two solution" do
    assert {:ok, @part_two_solution} == AoC.run(2024, 4, :part_two)
  end
end
