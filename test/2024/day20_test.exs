defmodule Aoc2024.Solutions.Y24.Day20Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day20, as: Solution, warn: false
  use ExUnit.Case, async: true

  # defp solve(input, part) do
  #   problem =
  #     input
  #     |> Input.as_file()
  #     |> Solution.parse(part)

  #   apply(Solution, part, [problem])
  # end

  # test "part one example" do
  #   input = ~S"""
  #   ###############
  #   #...#...#.....#
  #   #.#.#.#.#.###.#
  #   #S#...#.#.#...#
  #   #######.#.#.###
  #   #######.#.#...#
  #   #######.#.###.#
  #   ###..E#...#...#
  #   ###.#######.###
  #   #...###...#...#
  #   #.#####.#.###.#
  #   #.#...#.#.#...#
  #   #.#.#.#.#.#.###
  #   #...#...#...###
  #   ###############
  #   """

  #   assert 44 == solve(input, :part_one)
  # end

  @part_one_solution 1387

  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2024, 20, :part_one)
  end

  # test "part two example" do
  #   input = ~S"""
  #   ###############
  #   #...#...#.....#
  #   #.#.#.#.#.###.#
  #   #S#...#.#.#...#
  #   #######.#.#.###
  #   #######.#.#...#
  #   #######.#.###.#
  #   ###..E#...#...#
  #   ###.#######.###
  #   #...###...#...#
  #   #.#####.#.###.#
  #   #.#...#.#.#...#
  #   #.#.#.#.#.#.###
  #   #...#...#...###
  #   ###############
  #   """

  #   assert 44 == solve(input, :part_two)
  # end

  @part_two_solution 1_015_092

  test "part two solution" do
    assert {:ok, @part_two_solution} == AoC.run(2024, 20, :part_two)
  end
end
