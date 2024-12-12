defmodule Aoc2024.Solutions.Y24.Day12 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
  end

  def part_one(problem) do
    :ets.new(:store, [:named_table, :public, :ordered_set, :protected])
    build_matrix(problem)

    plots = :ets.tab2list(:store)

    result =
      Enum.reduce(plots, 0, fn {{x, y}, _req, _}, acc ->
        case :ets.lookup(:store, {x, y}) do
          [] ->
            acc

          [{_, req_type, _visited} = plot] ->
            case build_gardens([plot], req_type) do
              {0, 0, 0} ->
                acc

              {plot, fence, _} ->
                acc + plot * fence
            end
        end
      end)

    :ets.delete(:store)
    result
  end

  def part_two(problem) do
    :ets.new(:store, [:named_table, :public, :ordered_set, :protected])
    build_matrix(problem)

    plots = :ets.tab2list(:store)

    result =
      Enum.reduce(plots, 0, fn {{x, y}, _req, _}, acc ->
        case :ets.lookup(:store, {x, y}) do
          [] ->
            acc

          [{_, req_type, _visited} = plot] ->
            case build_gardens([plot], req_type) do
              {0, 0, 0} ->
                acc

              {plot, _fence, corners} ->
                acc + plot * corners
            end
        end
      end)

    :ets.delete(:store)
    result
  end

  def build_gardens([], _req_type), do: {0, 1, 0}

  def build_gardens([{{x, y}, type, visited}], req_type) do
    cond do
      type == req_type and visited == false ->
        :ets.insert(:store, {{x, y}, req_type, true})

        corner = check_for_corners(x, y, type)

        {south_plot, south_fence, south_corners} =
          build_gardens(:ets.lookup(:store, {x, y + 1}), req_type)

        {north_plot, north_fence, north_corners} =
          build_gardens(:ets.lookup(:store, {x, y - 1}), req_type)

        {west_plot, west_fence, west_corners} =
          build_gardens(:ets.lookup(:store, {x - 1, y}), req_type)

        {east_plot, east_fence, east_corners} =
          build_gardens(:ets.lookup(:store, {x + 1, y}), req_type)

        {south_plot + north_plot + west_plot + east_plot + 1,
         south_fence + north_fence + west_fence + east_fence,
         south_corners + north_corners + west_corners + east_corners + corner}

      type == req_type and visited == true ->
        {0, 0, 0}

      type != req_type ->
        {0, 1, 0}
    end
  end

  def check_for_corners(x, y, type) do
    n = is_requested_type?(x, y - 1, type)
    ne = is_requested_type?(x + 1, y - 1, type)
    e = is_requested_type?(x + 1, y, type)
    se = is_requested_type?(x + 1, y + 1, type)
    s = is_requested_type?(x, y + 1, type)
    sw = is_requested_type?(x - 1, y + 1, type)
    w = is_requested_type?(x - 1, y, type)
    nw = is_requested_type?(x - 1, y - 1, type)

    check_for_corner(n, ne, e) + check_for_corner(e, se, s) + check_for_corner(s, sw, w) +
      check_for_corner(w, nw, n)
  end

  def check_for_corner(n, ne, e) do
    cond do
      n == false and e == false ->
        1

      n == true and ne == false and e == true ->
        1

      true ->
        0
    end
  end

  def is_requested_type?(x, y, type) do
    case :ets.lookup(:store, {x, y}) do
      [{_, req_type, _}] ->
        req_type == type

      [] ->
        false
    end
  end

  def build_matrix(grid) do
    Enum.with_index(grid)
    |> Enum.each(fn row ->
      build_matrix_row(row)
    end)
  end

  def build_matrix_row({row, row_index}) do
    row
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.each(fn {char, col_index} ->
      :ets.insert(:store, {{col_index, row_index}, char, false})
    end)
  end
end
