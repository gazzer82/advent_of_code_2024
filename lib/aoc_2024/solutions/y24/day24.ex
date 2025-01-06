defmodule Aoc2024.Solutions.Y24.Day24 do
  alias AoC.Input

  def parse(input, _part) do
    [starting_position, gates] = Input.read!(input) |> String.split("\n\n", trim: true)

    gates =
      gates
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn gate, acc ->
        [ips, op] = gate |> String.split(" -> ", trim: true)
        [ip1, logic, ip2] = ips |> String.split(" ", trim: true)

        Map.put(acc, op |> String.to_atom(), %{
          ip1: ip1 |> String.to_atom(),
          logic: logic |> String.to_atom(),
          ip2: ip2 |> String.to_atom()
        })
      end)

    starting_position =
      starting_position
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn wire, acc ->
        [wire, value] = wire |> String.split(": ", trim: true)
        Map.put(acc, wire |> String.to_atom(), value |> String.to_integer())
      end)

    {starting_position, gates}
  end

  def part_one({starting_position, gates}) do
    {result, _} =
      get_destination_wires(gates)
      |> Enum.map(fn {key, value} ->
        {key, calculate_wire_value(gates, starting_position, value)}
      end)
      |> Enum.sort()
      |> Enum.map(fn {_, value} -> value end)
      |> Enum.reverse()
      |> Enum.join("")
      |> Integer.parse(2)

    result
  end

  def calculate_wire_value(gates, starting_position, %{ip1: ip1_key, logic: logic, ip2: ip2_key}) do
    ip1 =
      Map.get(
        starting_position,
        ip1_key
      )

    ip1 =
      if ip1 == nil,
        do:
          calculate_wire_value(
            gates,
            starting_position,
            Map.get(gates, ip1_key, {:not_found, ip1_key})
          ),
        else: ip1

    ip2 =
      Map.get(
        starting_position,
        ip2_key
      )

    ip2 =
      if ip2 == nil,
        do:
          calculate_wire_value(
            gates,
            starting_position,
            Map.get(gates, ip2_key, {:not_found, ip2})
          ),
        else: ip2

    case logic do
      :AND -> if ip1 == 1 && ip2 == 1, do: 1, else: 0
      :OR -> if ip1 == 1 || ip2 == 1, do: 1, else: 0
      :XOR -> if ip1 != ip2, do: 1, else: 0
    end
  end

  def get_destination_wires(gates) do
    Map.to_list(gates)
    |> Enum.filter(fn {k, _v} ->
      k |> Atom.to_string() |> String.starts_with?("z")
    end)
  end

  def part_two({starting_position, gates}) do
    starting_split =
      Map.to_list(starting_position)
      |> Enum.sort()
      |> Enum.split_with(fn {k, _v} ->
        Atom.to_string(k) |> String.first() == "y"
      end)
      |> get_totals()

    result =
      get_destination_wires(gates)
      |> Enum.map(fn {key, value} ->
        {key, calculate_wire_value(gates, starting_position, value)}
      end)
      |> Enum.sort()
      |> Enum.map(fn {_, value} -> value end)
      |> Enum.reverse()
      |> Enum.join("")
      |> String.split("", trim: true)
      |> drop_zeros()

    {y_total, x_total} = starting_split

    y_x_total = y_total + x_total
    y_x_total_binary = Integer.to_string(y_x_total, 2)

    {result_int, _} = Integer.parse(result, 2)

    {result_int == y_x_total, result_int, y_x_total, result, y_x_total_binary}

    # get_destination_wires(gates)
    # |> Enum.sort_by(fn {key, _value} -> key end)
    # |> Enum.map(fn {key, value} ->
    #   {key, trace_gate_sum(gates, starting_position, value, 0)}
    # end)

    # get_destination_wires(gates)
    # |> Enum.sort_by(fn {key, _value} -> key end)
    # |> Enum.filter(fn {key, _} ->
    #   key in [
    #     :z32,
    #     :z33,
    #     :z34,
    #     :z35
    #   ]
    # end)
    # |> Enum.reduce(Graphvix.Graph.new(), fn {key, _value}, _graph ->
    #   graph = Graphvix.Graph.new()
    #   gate = Map.get(gates, key)

    #   {graph, vertex} = Graphvix.Graph.add_vertex(graph, key)

    #   trace_gate(
    #     gates,
    #     starting_position,
    #     gate,
    #     vertex,
    #     graph
    #   )
    #   |> Graphvix.Graph.compile("dot/#{key}.png")
    # end)
  end

  def get_totals({y, x}) do
    {y_total, _} =
      y
      |> Enum.map(fn {_, value} -> value end)
      |> Enum.reverse()
      |> Enum.join("")
      |> Integer.parse(2)

    {x_total, _} =
      x
      |> Enum.map(fn {_, value} -> value end)
      |> Enum.reverse()
      |> Enum.join("")
      |> Integer.parse(2)

    {y_total, x_total}
  end

  def trace_gate_sum(
        gates,
        starting_position,
        %{ip1: ip1_key, logic: _logic, ip2: ip2_key},
        acc
      ) do
    ip1 =
      Map.get(
        starting_position,
        ip1_key
      )

    acc1 =
      if ip1 == nil,
        do:
          acc +
            trace_gate_sum(
              gates,
              starting_position,
              Map.get(gates, ip1_key, {:not_found, ip1_key}),
              acc
            ),
        else: acc + 1

    ip2 =
      Map.get(
        starting_position,
        ip2_key
      )

    acc2 =
      if ip2 == nil,
        do:
          acc +
            trace_gate_sum(
              gates,
              starting_position,
              Map.get(gates, ip2_key, {:not_found, ip2}),
              acc
            ),
        else: acc + 1

    acc1 + acc2
  end

  def trace_gate(
        gates,
        starting_position,
        %{ip1: ip1_key, logic: logic, ip2: ip2_key},
        upstream,
        graph
      ) do
    operation_key = "#{ip1_key}_#{ip2_key}_#{logic}" |> String.to_atom()

    {graph, operation_vertex} = Graphvix.Graph.add_vertex(graph, operation_key, label: logic)
    {graph, ip1_vertex} = Graphvix.Graph.add_vertex(graph, ip1_key)
    {graph, ip2_vertex} = Graphvix.Graph.add_vertex(graph, ip2_key)

    {graph, _} =
      Graphvix.Graph.add_edge(
        graph,
        upstream,
        operation_vertex
      )

    {graph, _} =
      Graphvix.Graph.add_edge(
        graph,
        operation_vertex,
        ip1_vertex
      )

    {graph, _} =
      Graphvix.Graph.add_edge(
        graph,
        operation_vertex,
        ip2_vertex
      )

    # {graph, ip1_vertex} = Graphvix.Graph.add_vertex(graph, ip1_key)
    # {graph, ip2_vertex} = Graphvix.Graph.add_vertex(graph, ip2_key)

    # {graph, _} =
    #   Graphvix.Graph.add_edge(
    #     graph,
    #     upstream,
    #     operation_vertex
    #   )

    # {graph, _} =
    #   Graphvix.Graph.add_edge(
    #     graph,
    #     upstream,
    #     ip1_vertex
    #   )

    # {graph, _} =
    #   Graphvix.Graph.add_edge(
    #     graph,
    #     upstream,
    #     ip2_vertex
    #   )

    ip1 =
      Map.get(
        starting_position,
        ip1_key
      )

    graph =
      if ip1 == nil,
        do:
          trace_gate(
            gates,
            starting_position,
            Map.get(gates, ip1_key, {:not_found, ip1_key}),
            ip1_vertex,
            graph
          ),
        else: graph

    ip2 =
      Map.get(
        starting_position,
        ip2_key
      )

    graph =
      if ip2 == nil,
        do:
          trace_gate(
            gates,
            starting_position,
            Map.get(gates, ip2_key, {:not_found, ip2}),
            ip2_vertex,
            graph
          ),
        else: graph

    graph
  end

  #   def trace_gate(
  #       gates,
  #       starting_position,
  #       %{ip1: ip1_key, logic: logic, ip2: ip2_key},
  #       upstream,
  #       graph
  #     ) do
  #   operation_key = "#{ip1_key}_#{ip2_key}_#{logic}" |> String.to_atom()

  #   graph =
  #     Graph.add_vertex(graph, ip1_key, ip1_key)
  #     |> Graph.add_vertex(ip2_key, ip2_key)
  #     # |> Graph.add_vertex(operation_key, logic)
  #     # |> Graph.add_edge(upstream, operation_key)
  #     |> Graph.add_edge(upstream, ip1_key)
  #     |> Graph.add_edge(upstream, ip2_key)

  #   ip1 =
  #     Map.get(
  #       starting_position,
  #       ip1_key
  #     )

  #   graph =
  #     if ip1 == nil,
  #       do:
  #         trace_gate(
  #           gates,
  #           starting_position,
  #           Map.get(gates, ip1_key, {:not_found, ip1_key}),
  #           ip1_key,
  #           graph
  #         ),
  #       else: graph

  #   ip2 =
  #     Map.get(
  #       starting_position,
  #       ip2_key
  #     )

  #   graph =
  #     if ip2 == nil,
  #       do:
  #         trace_gate(
  #           gates,
  #           starting_position,
  #           Map.get(gates, ip2_key, {:not_found, ip2}),
  #           ip2_key,
  #           graph
  #         ),
  #       else: graph

  #   graph
  # end

  def drop_zeros(input) do
    {_, result} =
      input
      |> Enum.reduce({false, ""}, fn val, {cont, acc} ->
        if cont do
          {cont, acc <> val}
        else
          if val == "1", do: {true, acc <> val}, else: {false, acc}
        end
      end)

    if result == "" do
      "0"
    else
      result
    end
  end
end
