defmodule Aoc2024.Solutions.Y24.Day14 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(fn robot ->
      [rob, speed] = String.split(robot, " ", trim: true)
      {get_x_y(rob), get_x_y(speed)}
    end)
  end

  def get_x_y(loc) do
    [x, y] = String.split(loc, ",", trim: true)
    x = String.split(x, "=", trim: true) |> List.last() |> String.to_integer()
    y = String.to_integer(y)
    {x, y}
  end

  def part_one(problem) do
    grid_x = 100
    grid_y = 102
    middle_x = 50
    middle_y = 51

    {a, b, c, d} =
      problem
      |> perform_moves({grid_x, grid_y}, 100, 0)
      # |> Enum.map(&perform_moves(&1, {grid_x, grid_y}, 100, 0))
      |> Enum.reduce({0, 0, 0, 0}, fn robot, acc ->
        acc = find_quadrant(robot, acc, {middle_x, middle_y})
        acc
      end)

    a * b * c * d
  end

  def part_two(problem) do
    grid_x = 100
    grid_y = 102

    problem
    |> perform_moves_pt_2({grid_x, grid_y}, 8000, 0)
  end

  def find_quadrant(
        {{loc_x, loc_y}, _},
        {quad_1, quad_2, quad_3, quad_4} = acc,
        {middle_x, middle_y}
      ) do
    cond do
      loc_x < middle_x && loc_y < middle_y ->
        {quad_1 + 1, quad_2, quad_3, quad_4}

      loc_x > middle_x && loc_y < middle_y ->
        {quad_1, quad_2 + 1, quad_3, quad_4}

      loc_x < middle_x && loc_y > middle_y ->
        {quad_1, quad_2, quad_3 + 1, quad_4}

      loc_x > middle_x && loc_y > middle_y ->
        {quad_1, quad_2, quad_3, quad_4 + 1}

      true ->
        acc
    end
  end

  def perform_moves(robots, {_grid_x, _grid_y}, count, acc) when acc == count, do: robots

  def perform_moves(robots, {grid_x, grid_y}, count, acc) do
    robots =
      Enum.map(robots, fn robot ->
        perform_move(robot, {grid_x, grid_y})
      end)

    perform_moves(robots, {grid_x, grid_y}, count, acc + 1)
  end

  def perform_moves_pt_2(robots, {_grid_x, _grid_y}, count, acc) when acc == count, do: robots

  @first_1 59
  @diff_1 103
  @tick_1 Enum.map(1..100, fn n -> @first_1 + (n - 1) * @diff_1 end)
  @first_2 82
  @diff_2 101
  @tick_2 Enum.map(1..100, fn n -> @first_2 + (n - 1) * @diff_2 end)
  @ticks @tick_1 ++ @tick_2

  def perform_moves_pt_2(robots, {grid_x, grid_y}, count, acc) do
    robots =
      Enum.map(robots, fn robot ->
        perform_move(robot, {grid_x, grid_y})
      end)

    if acc in @ticks do
      if check_for_tree(robots) do
        acc
      else
        perform_moves_pt_2(robots, {grid_x, grid_y}, count, acc + 1)
      end
    else
      perform_moves_pt_2(robots, {grid_x, grid_y}, count, acc + 1)
    end
  end

  def check_for_tree(robots) do
    grid = for _ <- 0..102, do: for(_ <- 0..100, do: ".")

    Enum.reduce(robots, grid, fn {{x, y}, _}, acc ->
      List.update_at(acc, y, fn row ->
        List.update_at(row, x, fn _ -> "#" end)
      end)
    end)
    |> Enum.join(" ")
    |> String.contains?("##########")
  end

  def print_coordinates_grid(coordinates, acc) do
    grid = for _ <- 0..102, do: for(_ <- 0..100, do: ".")

    updated_grid =
      Enum.reduce(coordinates, grid, fn {{x, y}, _}, acc ->
        List.update_at(acc, y, fn row ->
          List.update_at(row, x, fn _ -> "#" end)
        end)
      end)

    file =
      Enum.reduce(updated_grid, "", fn row, acc ->
        acc <> Enum.join(row, "") <> "\n"
      end)

    File.write!("output_#{acc}.txt", file)
  end

  def perform_move({{x, y}, {speed_x, speed_y}}, {grid_x, grid_y}) do
    updated_x = calulate_next_position(x, speed_x, grid_x)
    updated_y = calulate_next_position(y, speed_y, grid_y)
    {{updated_x, updated_y}, {speed_x, speed_y}}
  end

  def calulate_next_position(current, speed, grid_size) when current + speed > grid_size do
    current - 1 + speed - grid_size
  end

  def calulate_next_position(current, speed, grid_size) when current + speed < 0 do
    grid_size + 1 + current + speed
  end

  def calulate_next_position(current, speed, _grid_size) do
    current + speed
  end
end
