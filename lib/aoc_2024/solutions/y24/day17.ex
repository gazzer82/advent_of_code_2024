defmodule Aoc2024.Solutions.Y24.Day17 do
  alias AoC.Input

  def parse(input, _part) do
    [registers, program] = Input.read!(input) |> String.split("\n\n", trim: true)

    [[_, a], [_, b], [_, c]] =
      registers |> String.split("\n", trim: true) |> Enum.map(&String.split(&1, ": "))

    program =
      program
      |> String.split(":", trim: true)
      |> Enum.at(1)
      |> String.trim()
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    {%{
       register_a: String.to_integer(a),
       register_b: String.to_integer(b),
       register_c: String.to_integer(c)
     }, program}
  end

  def part_one({state, program}) do
    {_state, output} = instruction(program, state, [], 0)
    Enum.join(output, ",")
  end

  def instruction(program, state, output, pointer) when pointer >= length(program) - 1 do
    {state, output}
  end

  def instruction(
        program,
        %{
          register_a: register_a,
          register_b: register_b,
          register_c: register_c
        } = state,
        output,
        pointer
      ) do
    opcode = Enum.at(program, pointer)
    operand = Enum.at(program, pointer + 1)

    case opcode do
      0 ->
        updated_register_a =
          (register_a / :math.pow(2, operand(operand, state)))
          |> trunc()

        instruction(program, Map.put(state, :register_a, updated_register_a), output, pointer + 2)

      1 ->
        instruction(
          program,
          Map.put(state, :register_b, Bitwise.bxor(register_b, operand)),
          output,
          pointer + 2
        )

      2 ->
        instruction(
          program,
          Map.put(state, :register_b, Integer.mod(operand(operand, state), 8)),
          output,
          pointer + 2
        )

      3 ->
        if register_a != 0 do
          instruction(program, state, output, operand)
        else
          instruction(program, state, output, pointer + 2)
        end

      4 ->
        instruction(
          program,
          Map.put(state, :register_b, Bitwise.bxor(register_b, register_c)),
          output,
          pointer + 2
        )

      5 ->
        instruction(
          program,
          state,
          output ++ [Integer.mod(operand(operand, state), 8)],
          pointer + 2
        )

      6 ->
        updated_register_b =
          (register_a / :math.pow(2, operand(operand, state)))
          |> trunc()

        instruction(program, Map.put(state, :register_b, updated_register_b), output, pointer + 2)

      7 ->
        updated_register_c =
          (register_a / :math.pow(2, operand(operand, state)))
          |> trunc()

        instruction(program, Map.put(state, :register_c, updated_register_c), output, pointer + 2)
    end
  end

  def operand(combo_operand, %{
        register_a: register_a,
        register_b: register_b,
        register_c: register_c
      }) do
    case combo_operand do
      4 ->
        register_a

      5 ->
        register_b

      6 ->
        register_c

      7 ->
        throw("Not implemented, Invalid combo operand")

      _ ->
        combo_operand
    end
  end

  def part_two({_state, program}) do
    program_reversed = Enum.reverse(program)

    calculate_register_a(program, program_reversed, 0, 0)
  end

  def calculate_register_a(program, _program_reversed, index, acc)
      when index == length(program) do
    acc
  end

  def calculate_register_a(program, program_reversed, index, acc) do
    slice = Enum.take(program_reversed, index + 1)

    Enum.reduce_while(generate_options(acc), :none_found, fn option, acc ->
      state = %{register_a: option, register_b: 0, register_c: 0}

      {_state, output} = instruction(program, state, [], 0)

      if output |> Enum.reverse() == slice do
        result = calculate_register_a(program, program_reversed, index + 1, option)

        if result == :none_found do
          {:cont, acc}
        else
          {:halt, result}
        end
      else
        {:cont, acc}
      end
    end)
  end

  def generate_options(current) do
    Enum.map(0..7, fn x -> current * 8 + x end)
  end
end
