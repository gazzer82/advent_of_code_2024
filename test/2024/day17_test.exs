defmodule Aoc2024.Solutions.Y24.Day17Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day17, as: Solution, warn: false
  use ExUnit.Case, async: true

  defp solve(input, part) do
    problem =
      input
      |> Input.as_file()
      |> Solution.parse(part)

    apply(Solution, part, [problem])
  end

  test "part one example" do
    # # If register C contains 9, the program 2,6 would set register B to 1.
    # input_1 = ~S"""
    # Register A: 0
    # Register B: 0
    # Register C: 9

    # Program: 2,6
    # """

    # assert {%{register_c: 9, register_b: 1, register_a: 0}, []} == solve(input_1, :part_one)

    # # If register A contains 10, the program 5,0,5,1,5,4 would output 0,1,2.
    # input_2 = ~S"""
    # Register A: 10
    # Register B: 0
    # Register C: 0

    # Program: 5,0,5,1,5,4
    # """

    # assert {%{register_c: 0, register_b: 0, register_a: 10}, [0, 1, 2]} ==
    #          solve(input_2, :part_one)

    # # # If register A contains 2024, the program 0,1,5,4,3,0 would output 4,2,5,6,7,7,7,7,3,1,0 and leave 0 in register A.
    # input_3 = ~S"""
    # Register A: 2024
    # Register B: 0
    # Register C: 0

    # Program: 0,1,5,4,3,0
    # """

    # assert {%{register_c: 0, register_b: 0, register_a: 0}, [4, 2, 5, 6, 7, 7, 7, 7, 3, 1, 0]} ==
    #          solve(input_3, :part_one)

    # # If register B contains 29, the program 1,7 would set register B to 26.
    # input_4 = ~S"""
    # Register A: 0
    # Register B: 29
    # Register C: 0

    # Program: 1,7
    # """

    # assert {%{register_c: 0, register_b: 26, register_a: 0}, []} ==
    #          solve(input_4, :part_one)

    # # If register B contains 2024 and register C contains 43690, the program 4,0 would set register B to 44354
    # input_5 = ~S"""
    # Register A: 0
    # Register B: 2024
    # Register C: 43690

    # Program: 4,0
    # """

    # assert {%{register_c: 43690, register_b: 44354, register_a: 0}, []} ==
    #          solve(input_5, :part_one)

    # its final output will be 4,6,3,5,6,3,5,2,1,0
    input_6 = ~S"""
    Register A: 156985331222018
    Register B: 0
    Register C: 0

    Program: 0,1,5,4,3,0
    """

    assert "4,6,3,5,6,3,5,2,1,0" ==
             solve(input_6, :part_one)
  end

  # Combo operands 0 through 3 represent literal values 0 through 3.
  # Combo operand 4 represents the value of register A.
  # Combo operand 5 represents the value of register B.
  # Combo operand 6 represents the value of register C.
  # Combo operand 7 is reserved and will not appear in valid programs.

  # The adv instruction (opcode 0) performs division. The numerator is the value in the A register. The denominator is found by raising 2 to the power of the instruction's combo operand. (So, an operand of 2 would divide A by 4 (2^2); an operand of 5 would divide A by 2^B.) The result of the division operation is truncated to an integer and then written to the A register.

  # The bxl instruction (opcode 1) calculates the bitwise XOR of register B and the instruction's literal operand, then stores the result in register B.

  # The bst instruction (opcode 2) calculates the value of its combo operand modulo 8 (thereby keeping only its lowest 3 bits), then writes that value to the B register.

  # The jnz instruction (opcode 3) does nothing if the A register is 0. However, if the A register is not zero, it jumps by setting the instruction pointer to the value of its literal operand; if this instruction jumps, the instruction pointer is not increased by 2 after this instruction.

  # The bxc instruction (opcode 4) calculates the bitwise XOR of register B and register C, then stores the result in register B. (For legacy reasons, this instruction reads an operand but ignores it.)

  # The out instruction (opcode 5) calculates the value of its combo operand modulo 8, then outputs that value. (If a program outputs multiple values, they are separated by commas.)

  # The bdv instruction (opcode 6) works exactly like the adv instruction except that the result is stored in the B register. (The numerator is still read from the A register.)

  # The cdv instruction (opcode 7) works exactly like the adv instruction except that the result is stored in the C register. (The numerator is still read from the A register.)

  # @part_one_solution CHANGE_ME
  #
  # test "part one solution" do
  #   assert {:ok, @part_one_solution} == AoC.run(2024, 17, :part_one)
  # end

  # test "part two example" do
  #   input = ~S"""
  #   Register A: 0
  #   Register B: 0
  #   Register C: 0

  #   Program: 0,3,5,4,3,0
  #   """

  #   assert 117_440 == solve(input, :part_two)
  # end

  test "part two testing" do
    input = ~S"""
    Register A: 2
    Register B: 0
    Register C: 0

    Program: 2,4,1,4,7,5,4,1,1,4,5,5,0,3,3,0
    """

    assert "2,4,1,4,7,5,4,1,1,4,5,5,0,3,3,0" == solve(input, :part_two)
  end

  # @part_two_solution CHANGE_ME
  #
  # test "part two solution" do
  #   assert {:ok, @part_two_solution} == AoC.run(2024, 17, :part_two)
  # end
end

# 24 - 35184372089083
# 241 - 35184372090370 - 1287
# 2414 - 35184372303099 - 212729
# 24147 - 35184372307195 - 4096
# 241475 - 35184372549122 - 241927

# 2414751 - 35184372549122 -
# 2414751 - 35184372569339 - 20,217
# 2414757 - 35184373597698 - 1,028,359
# 2414757 - 35184373605890 - 8,192
# 2414757 - 35184373617915 - 12,025
# 2414751 - 35184374646274 - 1,028,359
# 2414751 - 35184374666491 - 20,217
# 2414753 - 35184375694850 - 1,028,359
# 2414753 - 35184375703042 - 8,192
# 2414753 - 35184375715067 - 12,025
# 2414751 - 35184374646274 - 1,028,359
# 2414751 - 35184374666491 - 20,217
# 2414752 - 35184377792002 - 1,028,359

# 2414751 - 35_184_378_860_795

# 35_184_378_860_795

# 35_184_359_441_922
# 35_184_377_792_002
# 35_184_414_492_162 - 36,700,160
# 35_184_487_892_482 - 73,400,320
# 35_184_890_545_666 - 402,653,184
# 35_188_648_642_050 - 3_758_096_384
# 35_196_164_834_818 - 7_516_192_768
# 43_727_043_626_498 - 8,530,878,791,680
# 197_658_671_515_138
# 200_965_796_333_058 - 3,307,124,817,920

# 6,614,249,635,840

# 200_965_796_333_058

# 207,580,045,968,898

# 15,032,385,536
# 30,064,771,072
# 60,129,542,144
# 120,259,084,288
# 240,518,168,576
# 481,036,337,152
# 962,072,674,304
# 1,924,145,348,608
# 3,848,290,697,216
# 7,696,581,394,432
# 15,393,162,788,864

# 15,032,385,536

# 35308907726338

# 2,097,152
