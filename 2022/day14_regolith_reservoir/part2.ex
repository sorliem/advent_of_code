defmodule Day14RegolithReservoir do
  @moduledoc """
  """

  @pid_table :pid_table
  @rock "#"
  @air "."
  @sand "+"

  # INCOMPLETE DOES NOT WORK
  def run(file) do
    rock_locations =
      file
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(&construct_wall_coords/1)
      |> List.flatten()
      |> Enum.uniq()

    :ets.new(@pid_table, [:set, :public, :named_table, read_concurrency: true])

    {_x, max_y} =
      Enum.max_by(rock_locations, fn {_x, y} -> y end)

    :ets.insert(@pid_table, {:max_y, max_y})
    :ets.insert(@pid_table, {:max_y_plus2, max_y+2})
    :ets.lookup(@pid_table, :max_y_plus2)
    |> IO.inspect(label: "max_y_plus2 out")

    for location <- rock_locations do
      spawn_and_insert(location, @rock)
    end

    IO.puts("map after rock spawn")
    print_map()

    orig_pid = self()
    orig_ref = make_ref()

    sand_count =
      Enum.reduce_while(1..100000, 0, fn _, acc ->
        do_move({500, 0}, {orig_pid, orig_ref})

        receive do
          {^orig_ref, :sand_resting} ->
            {:cont, acc+1}

          {^orig_ref, :void_reached} ->
            IO.puts("void reached after #{acc} placements of sand")
            {:cont, acc+1}

          {^orig_ref, :pyramid_complete} ->
            IO.puts("pyramid complete after #{acc+1} placements of sand")
            {:halt, acc+1}
        end
      end)

    print_map()
    IO.puts("pyramid complete after #{sand_count} placements of sand")
  end

  defp print_map() do
    pid_map = :ets.tab2list(@pid_table) |> Enum.reject(fn {k, _} -> is_atom(k) end)

    {{min_x, _y}, _pid} = Enum.min_by(pid_map, fn {{x, _y}, _pid} -> x end)
    {{max_x, _y}, _pid} = Enum.max_by(pid_map, fn {{x, _y}, _pid} -> x end)
    {{_x, min_y}, _pid} = Enum.min_by(pid_map, fn {{_x, y}, _pid} -> y end)
    {{_x, max_y}, _pid} = Enum.max_by(pid_map, fn {{_x, y}, _pid} -> y end)


    xrng = Range.new(min_x, max_x)
    yrng = Range.new(min_y, max_y)

    for y <- Enum.to_list(yrng) do
      line =
        for x <- Enum.to_list(xrng), into: "" do
          if pid = Enum.find_value(pid_map, fn {{^x,^y}, pid} -> pid; _ -> false end) do
            ref = make_ref()
            send(pid, {:get_type, ref, self()})

            receive do
              {^ref, type} -> type
            end
          else
            @air
          end
        end

      IO.puts(line)
    end
  end

  defp do_move({x,y}=coord, {o_pid, o_ref} = orig_info) do
    [{_, max_y}] = :ets.lookup(@pid_table, :max_y)

    cond do
      can_move?(coord, :down) ->
        send_to(down(coord), :incoming_sand, orig_info)

      can_move?(coord, :down_left) ->
        send_to(down_left(coord), :incoming_sand, orig_info)

      can_move?(coord, :down_right) ->
        send_to(down_right(coord), :incoming_sand, orig_info)

      true ->
        # can't move, sand rests.
        if coord == {500,0} do
          send_to(coord, :store_sand, orig_info)
          send(o_pid, {o_ref, :pyramid_complete})
        else
          send_to(coord, :store_sand, orig_info)
        end
    end
  end

  defp can_move?(coord, dir) do
    to_coord =
      case dir do
        :down -> down(coord)
        :down_left -> down_left(coord)
        :down_right -> down_right(coord)
      end

    ref = make_ref()
    to_pid = lookup_pid(to_coord)
    send(to_pid, {:get_type, ref, self()})

    receive do
      {^ref, type} ->
        type == @air
    end
  end

  defp send_to(coord, msg, orig_info) do
    pid = lookup_pid(coord)
    send(pid, {msg, orig_info})
  end

  def loop_cell({x, y}, type) do
    receive do
      {:incoming_sand, orig_info} ->
        do_move({x,y}, orig_info)
        loop_cell({x, y}, type)

      {:get_type, ref, from} ->
        send(from, {ref, type})

        loop_cell({x, y}, type)

      {:store_sand, {orig_pid, orig_ref}} ->
        send(orig_pid, {orig_ref, :sand_resting})
        loop_cell({x, y}, @sand)
    end
  end

  defp lookup_pid(coord) do
    case :ets.lookup(@pid_table, coord) do
      [{^coord, pid}] ->
        pid

      _ ->
        spawn_and_insert(coord, @air)
    end
  end

  defp spawn_and_insert({_x,y} = coord, value) do
    [{_, max_y_plus2}] = :ets.lookup(@pid_table, :max_y_plus2)
    value = if y == max_y_plus2, do: @rock, else: value

    # if value == @rock do
    #   IO.puts("spawning rock at #{inspect coord}")
    # end

    pid = spawn(fn -> loop_cell(coord, value) end)
    insert_entry(coord, pid)

    pid
  end


  defp construct_wall_coords(line) do
    [head | tail] =  String.split(line, " -> ", trim: true)

    {_point, coords} =
      Enum.reduce(tail, {head, []}, fn point, {prev, acc} ->
        [sx, sy] =
          point
          |> String.split(",", parts: 2)
          |> Enum.map(&String.to_integer/1)

        [ex, ey] =
          prev
          |> String.split(",", parts: 2)
          |> Enum.map(&String.to_integer/1)

        coords = construct_coords({sx, sy}, {ex, ey})

        {point, [coords | acc]}
      end)

    coords
  end

  defp insert_entry(coord, pid) do
    :ets.insert(@pid_table, {coord, pid})
  end

  defp construct_coords({sx, sy}, {ex, ey}) do
    for x <- Range.new(sx, ex), y <- Range.new(sy, ey), do: {x, y}
  end

  defp down({x, y}), do: {x, y+1}
  defp down_left({x, y}), do: {x-1, y+1}
  defp down_right({x, y}), do: {x+1, y+1}
end

Day14RegolithReservoir.run("input")
