defmodule Aoc2024.Solutions.Y24.Day11Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day11, as: Solution, warn: false
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
  #   125 17
  #   """

  #   assert 55312 == solve(input, :part_one)
  # end

  # # 7
  # # 2097446912 14168 4048 2 0 2 4 40 48 2024 40 48 80 96 2 8 6 7 6 0 3 2
  # # 20974 46912 28676032 40 48 4048 1 4048 8096 4 0 4 8 20 24 4 0 4 8 8 0 9 6 4048 16192 12144 14168 12144 1 6072 4048

  # # 8
  # # 20974 46912 28676032 40 48 4048 1 4048 8096 4 0 4 8 20 24 4 0 4 8 8 0 9 6 4048 16192 12144 14168 12144 1 6072 4048
  # # 42451376, 94949888, 2867, 6032, 4, 0, 4, 8, 40, 48, 2024, 40, 48, 80, 96, 8096, 1, 8096, 16192, 2, 0, 2, 4, 8096, 1, 8096, 16192, 16192, 1, 18216, 12144, 40, 48, 32772608, 24579456, 28676032, 24579456, 2024, 60, 72, 40, 48

  # @part_one_solution 193_607

  # test "part one solution" do
  #   assert {:ok, @part_one_solution} == AoC.run(2024, 11, :part_one)
  # end

  # test "part two example" do
  #   input = ~S"""
  #   5910927 0 1 47 261223 94788 545 7771
  #   """

  #   assert 229_557_103_025_807 == solve(input, :part_two)
  # end

  # @part_two_solution 229_557_103_025_807

  # test "part two solution" do
  #   assert {:ok, @part_two_solution} == AoC.run(2024, 11, :part_two)
  # end
end
