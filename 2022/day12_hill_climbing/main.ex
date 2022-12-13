defmodule Day12HillClimbing do
  @moduledoc """
  """

  # DOES NOT WORK.
  def run(file) do
    pid_map =
      file
      |> File.read!()
      |> String.split("\n", trim: true)
      |> parse_map()
      |> Enum.map(&init_cell/1)
      |> Enum.into(%{})

    for {_, %{pid: pid}} <- pid_map do
      send(pid, pid_map: pid_map)
    end

    {_, %{pid: start_pid}} =
      Enum.find(pid_map, fn
        {_, %{height: 83}} -> true
        _ -> false
      end)

    send(start_pid, :start_msg)

    pid_map
  end

  defp parse_map(lines) do
    lines
    |> Enum.with_index()
    |> Enum.map(fn {line, idx} ->
      list = String.to_charlist(line)

      Enum.with_index(list)
      |> Enum.map(fn {cell, idx2} ->
        {{idx, idx2}, cell}
      end)
    end)
    |> List.flatten()
  end

  defp init_cell({{x, y}, 83}) do
    # start cell, ?S = 83
    pid = spawn(fn -> start_loop({x, y}, 83, [start_cell: true]) end)
    {{x, y}, %{pid: pid, height: 83}}
  end

  defp init_cell({{x, y}, 69}) do
    # end cell, ?E = 69
    pid = spawn(fn -> start_loop({x, y}, 69, [end_cell: true]) end)
    {{x, y}, %{pid: pid, height: 69}}
  end

  defp init_cell({{x, y}, height}) do
    pid = spawn(fn -> start_loop({x, y}, height) end)
    {{x, y}, %{pid: pid, height: height}}
  end

  def start_loop({x, y}, height, opts \\ []) do
    all_opts = [
      visits: [],
      out_nodes: [],
      visited: false
    ] ++ opts

    loop({x, y}, height, all_opts)
  end

  defp loop({x, y}, height, opts) do
    receive do
      [pid_map: pid_map] ->
        opts = Keyword.put(opts, :pid_map, pid_map)

        loop({x, y}, height, opts)

      :start_msg ->
        opts =
          Keyword.update(opts, :visits, [], fn visits ->
            [{x, y} | visits]
          end)

        send_to_unvisited({x, y}, height, :start, opts[:visits], opts[:pid_map])

        opts = Keyword.put(opts, :visited, true)

        loop({x, y}, height, Keyword.put(opts, :visited, true))

      {:visited?, from, ref} ->
        send(from, {ref, opts[:visited]})

        loop({x, y}, height, opts)

      {:visit_from, {vx, vy, from_dir, visit_chain}} ->
        opts =
          Keyword.update(opts, :visits, [], fn visits ->
            [{x, y} | visits]
          end)

        if height == ?E do
          IO.puts("GOT TO END!!, visit chain: #{inspect opts[:visit_chain]}")
        end

        IO.puts("visit from cell to #{from_dir}, {#{vx},#{vy}}")
        send_to_unvisited({x, y}, height, from_dir, opts[:visits], opts[:pid_map])

        opts = Keyword.put(opts, :visited, true)

        loop({x, y}, height, opts)

      msg ->
        IO.puts("cell {#{x}, #{y}} got msg #{msg}")

        loop({x, y}, height, opts)
    end
  end

  defp send_to_unvisited({x, y} = cell, height, :start, visit_chain, pid_map) do
    dirs = [down: down(cell), up: up(cell), left: left(cell), right: right(cell)]

    Enum.each(dirs, fn {dir, cell} ->

      if pid = Map.get(pid_map, cell)[:pid] do
        send(pid, {:visit_from, {x, y, opposite(dir), [cell]}})
      end
    end)
  end

  defp send_to_unvisited({x, y} = cell, height, from_dir, visit_chain, pid_map) do
    dirs = other_dirs(from_dir, cell)

    Enum.each(dirs, fn {dir, cell} ->
      if pid = Map.get(pid_map, cell)[:pid] do
        ref = make_ref()
        send(pid, {:visited?, self(), ref})

        already_visited? =
          receive do
            {^ref, visited} -> visited
          end

        n_height = Map.get(pid_map, cell)[:height]

        unless already_visited? and can_travel?(height, n_height) do
          send(pid, {:visit_from, {x, y, opposite(dir), visit_chain}})
        end
      else
        # invalid direction
      end
    end)
  end


  defp can_travel?(height, neighbor_height) do
    (neighbor_height - height) <= 1
  end

  defp opposite(:left), do: :right
  defp opposite(:right), do: :left
  defp opposite(:up), do: :down
  defp opposite(:down), do: :up

  defp other_dirs(:left, cell) do
    [down: down(cell), up: up(cell), right: right(cell)]
  end

  defp other_dirs(:right, cell) do
    [down: down(cell), up: up(cell), left: left(cell)]
  end

  defp other_dirs(:up, cell) do
    [down: down(cell), right: right(cell), left: left(cell)]
  end

  defp other_dirs(:down, cell) do
    [up: up(cell), right: right(cell), left: left(cell)]
  end

  defp down({x, y}), do: {x, y+1}
  defp up({x, y}), do: {x, y-1}
  defp left({x, y}), do: {x-1, y}
  defp right({x, y}), do: {x+1, y}
end

Day12HillClimbing.run("input.test")
