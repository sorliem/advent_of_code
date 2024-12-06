defmodule Day6 do
  @moduledoc """
  Day 6: Guard Gallivant
  """

  # @north {0, -1}
  # @east {1, 0}
  # @south {0, 1}
  # @west {-1, 0}

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
        IO.inspect({{x+new_xdir, y+new_ydir}, new_dirchar}, label: "visited, and turned")

        new_coords = 
          coords
          |> Map.put({x, y}, "X")
          |> Map.put({x+new_xdir, y+new_ydir}, new_dirchar)

        new_visited = if Map.get(coords, {x+new_xdir, y+new_ydir}) == ".", do: visited+1, else: visited
        walk(new_coords, new_dirchar, {x+new_xdir, y+new_ydir}, {new_xdir, new_ydir}, new_visited)

      val when val in [".", "X"] -> 
        IO.inspect({{x+xdir, y+ydir}, val}, label: "visited")

        new_coords = 
          coords
          |> Map.put({x, y}, "X")
          |> Map.put({x+xdir, y+ydir}, dirchar)

        new_visited = if val == ".", do: visited+1, else: visited

        walk(new_coords, dirchar, {x+xdir, y+ydir}, {xdir, ydir}, new_visited)
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

file = "input"

map = 
  File.read!(file)
  |> String.split("\n", trim: true)

Day6.part1(map)
