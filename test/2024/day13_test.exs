defmodule Aoc2024.Solutions.Y24.Day13Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day13, as: Solution, warn: false
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
  #   Button A: X+94, Y+34
  #   Button B: X+22, Y+67
  #   Prize: X=8400, Y=5400

  #   Button A: X+26, Y+66
  #   Button B: X+67, Y+21
  #   Prize: X=12748, Y=12176

  #   Button A: X+17, Y+86
  #   Button B: X+84, Y+37
  #   Prize: X=7870, Y=6450

  #   Button A: X+69, Y+23
  #   Button B: X+27, Y+71
  #   Prize: X=18641, Y=10279
  #   """

  #   assert 480 == solve(input, :part_one)
  # end

  # @part_one_solution 33427

  # test "part one solution" do
  #   assert {:ok, @part_one_solution} == AoC.run(2024, 13, :part_one)
  # end

  # test "part two example" do
  #   input = ~S"""
  #   Button A: X+94, Y+34
  #   Button B: X+22, Y+67
  #   Prize: X=8400, Y=5400

  #   Button A: X+26, Y+66
  #   Button B: X+67, Y+21
  #   Prize: X=12748, Y=12176

  #   Button A: X+17, Y+86
  #   Button B: X+84, Y+37
  #   Prize: X=7870, Y=6450

  #   Button A: X+69, Y+23
  #   Button B: X+27, Y+71
  #   Prize: X=18641, Y=10279
  #   """

  #   assert 875_318_608_908 == solve(input, :part_two)
  # end

  # @part_two_solution 91_649_162_972_270

  # test "part two solution" do
  #   assert {:ok, @part_two_solution} == AoC.run(2024, 13, :part_two)
  # end
end
