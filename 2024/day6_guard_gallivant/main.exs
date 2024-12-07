defmodule Day6 do
  @moduledoc """
  Day 6: Guard Gallivant
  """

  @north {-1, 0}
  @east {0, 1}
  @south {1, 0}
  @west {0, -1}

  def part1(map) do
    coords = 
      map
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, x}, acc -> 
        String.split(row, "", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c, y}, in_acc ->
            Map.put(in_acc, {x, y}, c)
        end)
      end)

    {{startx, starty}, "^"} =
      Enum.find(coords, fn 
        {_, "^"} = val -> val 
        _ -> false
      end)
    |> IO.inspect(label: "start coords")

    walk(coords, "^", {startx, starty}, @north)
    |> IO.inspect(label: "part1 answer")
  end

  defp walk(coords, dirchar, {x, y}, {xdir, ydir}, visited \\ 1) do
    # print_coords(coords)
    case Map.get(coords, {x+xdir, y+ydir}, :offgrid) do
      :offgrid -> 
        IO.inspect({x+xdir, y+ydir}, label: "OFF GRID AT")
        visited

      "#" -> 
        {{new_xdir, new_ydir}, new_dirchar} = cycle_dir({xdir, ydir})
        # IO.inspect({{x+new_xdir, y+new_ydir}, new_dirchar}, label: "visited, and turned")

        new_coords = 
          coords
          |> Map.put({x, y}, "X")
          |> Map.put({x+new_xdir, y+new_ydir}, new_dirchar)

        new_visited = if Map.get(coords, {x+new_xdir, y+new_ydir}) == ".", do: visited+1, else: visited
        walk(new_coords, new_dirchar, {x+new_xdir, y+new_ydir}, {new_xdir, new_ydir}, new_visited)

      val when val in [".", "X"] -> 
        # IO.inspect({{x+xdir, y+ydir}, val}, label: "visited")

        new_coords = 
          coords
          |> Map.put({x, y}, "X")
          |> Map.put({x+xdir, y+ydir}, dirchar)

        new_visited = if val == ".", do: visited+1, else: visited

        walk(new_coords, dirchar, {x+xdir, y+ydir}, {xdir, ydir}, new_visited)
    end
  end

  def part2(map) do
    coords = 
      map
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, x}, acc -> 
        String.split(row, "", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c, y}, in_acc ->
            Map.put(in_acc, {x, y}, c)
        end)
      end)
    print_coords(coords)

    {{startx, starty}, "^"} =
      Enum.find(coords, fn 
        {_, "^"} = val -> val 
        _ -> false
      end)
    |> IO.inspect(label: "start coords")

    coords
    # %{{7, 6} => ".", {6, 3} => ".", {6, 0} => "."}
    # %{{6, 3} => "."}
    # %{{29, 78} => "."}
    |> Enum.reduce(0, fn 
      {{x, y}, "."}, acc ->
        new_coords = Map.put(coords, {x, y}, "O")
        IO.inspect({x, y}, label: "blocking")
        if walk2(new_coords, {:queue.new(), :queue.new(), :queue.new()}, "^", {startx, starty}, @north) do
          acc + 1
        else
          acc
        end
      {_coord, _}, acc -> acc
    end)
    |> IO.inspect(label: "part2 answer")
  end

  defp walk2(coords, {queue, queue2, queue3}, dirchar, {x, y}, {xdir, ydir}, visited \\ 1) do
    # print_coords(coords)
    case Map.get(coords, {x+xdir, y+ydir}, :offgrid) do
      :offgrid -> 
        IO.inspect({x+xdir, y+ydir}, label: "OFF GRID AT")
        false

      val when val in ["#", "O"] -> 
        {is_cycle?, new_queue} = is_cycle?(queue, {x, y})
        # {is_cycle8?, new_queue2} = is_cycle?(queue2, {x, y}, 8)
        # {is_cycle36?, new_queue3} = is_cycle?(queue3, {x, y}, 36)
        # |> IO.inspect(label: "is_cycle36?")
        # if is_cycle? or is_cycle8? or is_cycle36? do
        if is_cycle? do
          IO.puts("IS A CYCLE!")
          true
        else
          {{new_xdir, new_ydir}, new_dirchar} = cycle_dir({xdir, ydir})
          # IO.inspect({{x+new_xdir, y+new_ydir}, new_dirchar}, label: "visited, and turned")

          new_coords = 
            coords
            |> Map.put({x, y}, "X")
            |> Map.put({x+new_xdir, y+new_ydir}, new_dirchar)

          new_visited = if Map.get(coords, {x+new_xdir, y+new_ydir}) == ".", do: visited+1, else: visited
          walk2(new_coords, {new_queue, queue2, queue3}, new_dirchar, {x+new_xdir, y+new_ydir}, {new_xdir, new_ydir}, new_visited)
        end

      val when val in [".", "X"] -> 
        # IO.inspect({{x+xdir, y+ydir}, val}, label: "visited")

        new_coords = 
          coords
          |> Map.put({x, y}, "X")
          |> Map.put({x+xdir, y+ydir}, dirchar)

        new_visited = if val == ".", do: visited+1, else: visited

        walk2(new_coords, {queue, queue2, queue3}, dirchar, {x+xdir, y+ydir}, {xdir, ydir}, new_visited)
    end
  end

  defp cycle_dir(dir) do
    case dir do
      @north -> {@east, ">"}
      @east -> {@south, "v"}
      @south -> {@west, "<"}
      @west -> {@north, "^"}
    end
  end

  defp is_cycle?(queue, in_coord, cycle_len \\ 4) do
    # IO.puts("")
    IO.inspect(in_coord, label: pad("coord coming in"))
    # before_coords = :queue.to_list(queue)
    # |> IO.inspect(label: pad("before_coords"))
    new_q = :queue.in(in_coord, queue)

    # case :queue.len(new_q) do
    #   len when len in [5, 9, 13, 17, 21, 25, 29, 33] ->
    #     IO.inspect(len, label: "queue is len")
    #     # check for cycle. 
    #     peeked = :queue.peek(new_q)
    #     if peeked == in_coord do
    #       {true, new_q} # returning updated queue doesn't matter
    #     else
    #       {false, new_q}
    #     end
    #
    #   37 ->
    #     IO.inspect(37, label: "queue is len")
    #     # check for cycle. 
    #     peeked = :queue.peek(new_q)
    #     if peeked == in_coord do
    #       {{:value, _out_coord}, new_queue} = :queue.out(new_q)
    #       {true, new_queue} # returning updated queue doesn't matter
    #     else
    #       {{:value, _out_coord}, new_queue} = :queue.out(new_q)
    #       {false, new_queue}
    #     end
    #
    #
    #
    #
    #   len ->
    #     IO.inspect(len, label: "len of queue size")
    #     {false, new_q}
    # end

    if :queue.len(new_q) == (cycle_len + 1) do
      # IO.inspect(:queue.to_list(new_q), label: pad("queue in"))
      {{:value, out_coord}, new_queue} = :queue.out(new_q)
      # IO.inspect(out_coord, label: pad("out_coord"))
      # after_coords = :queue.to_list(new_queue)
      # |> IO.inspect(label: pad("after_coords"))

      # if before_coords == after_coords do
      if out_coord == in_coord do
        {true, new_queue}
      else
        {false, new_queue}
      end
    else
      {false, new_q}
    end
  end

  defp pad(str, n \\ 15), do: String.pad_trailing(str, n)

  defp print_coords(coords) do
    str = 
      Enum.reduce(0..9, "", fn i, acc ->
        Enum.reduce(0..9, acc, fn j, in_acc ->
          in_acc <> Map.get(coords, {i, j})
        end)
        |> Kernel.<>("\n")
      end)

    IO.puts(str)
  end
end

file = "test_input"

map = 
  File.read!(file)
  |> String.split("\n", trim: true)

Day6.part1(map)
Day6.part2(map)
