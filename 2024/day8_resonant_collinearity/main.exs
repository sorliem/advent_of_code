defmodule Day8 do
  @moduledoc """
  Day8: Resnant
  """

  def part1(coords) do 
    {lenx, leny} = find_dimensions(coords)
    # |> IO.inspect(label: "dimensions")

    coord_pairings = 
      coords 
      |> Enum.reject(fn {_, "."} -> true; _ -> false end)
      # |> IO.inspect(label: "coords after reject")
      |> Enum.group_by(fn {_, freq} -> freq end)
      |> Enum.into(%{}, fn {freq, l} -> 
        coords_for_freq = Enum.map(l, fn {coord, _} -> coord end)

        pairs = for c1 <- coords_for_freq, c2 <- coords_for_freq, c1 != c2, do: {c1, c2}
        {freq, pairs}
      end)

    antinodes = 
      coord_pairings
      |> Enum.map(fn {_ant, pairings} ->
         new_pairings = 
          Enum.flat_map(pairings, fn {p1, p2} ->
            find_antinodes(p1, p2, {lenx, leny})
          end)

        new_pairings
      end)
      |> List.flatten()
      |> Enum.map(fn {_c1, _c2, [anti]} ->  anti end)
      |> Enum.uniq()

    Enum.reduce(antinodes, coords, fn {x, y}, acc ->
      Map.put(acc, {x, y}, "#")
    end)
    |> print_coords({lenx, leny})

    length(antinodes)
    |> IO.inspect(label: "part1 answer")
  end

  def part2(coords) do 
    {lenx, leny} = find_dimensions(coords)

    coord_pairings = 
      coords 
      |> Enum.reject(fn {_, "."} -> true; _ -> false end)
      # |> IO.inspect(label: "coords after reject")
      |> Enum.group_by(fn {_, freq} -> freq end)
      |> Enum.into(%{}, fn {freq, l} -> 
        coords_for_freq = Enum.map(l, fn {coord, _} -> coord end)

        pairs = for c1 <- coords_for_freq, c2 <- coords_for_freq, c1 != c2, do: {c1, c2}
        {freq, pairs}
      end)
    # |> IO.inspect(label: "coord pairings")

    antinodes = 
      coord_pairings
      |> Enum.map(fn {_ant, pairings} ->
         new_pairings = 
          Enum.flat_map(pairings, fn {p1, p2} ->
            find_antinodes2(p1, p2, {lenx, leny})
          end)

        new_pairings
      end)
      |> List.flatten()
      # |> Enum.map(fn {_c1, _c2, [anti]} ->  anti end)
      |> Enum.uniq()

    new_coords = 
      Enum.reduce(antinodes, coords, fn {x, y}, acc ->
        Map.put(acc, {x, y}, "#")
      end)

    print_coords(new_coords, {lenx, leny})

    length(antinodes)
    |> IO.inspect(label: "part2 answer")
  end

  def find_antinodes({x1, y1} = c1, {x2, y2} = c2, {lenx, leny}) do
    diffx = x2 - x1
    diffy = y2 - y1
    a1 = {x1 - diffx, y1 - diffy}
    a2 = {x2 + diffx, y2 + diffy}

    Enum.reduce([a1, a2], [], fn {ax, ay}, acc ->
      if is_oob?({ax, ay}, lenx, leny) do
        # IO.inspect({ax, ay}, label: "OUT OF BOUNDS {ax, ay}")
        acc
      else
        [{c1, c2, [{ax, ay}]} | acc]
      end
    end)
  end

  def find_antinodes2({x1, y1} = c1, {x2, y2} = c2, {lenx, leny}) do
    diffx = x2 - x1
    diffy = y2 - y1
    # a1 = {x1 - diffx, y1 - diffy}
    # a2 = {x2 + diffx, y2 + diffy}
    a1 = c1
    a2 = c2

    left_antinodes =
      Enum.reduce_while(0..lenx, {a1, []}, fn _i, {{ax, ay}, acc} ->
        {new_ax, new_ay} = {ax - diffx, ay - diffy}
        if is_oob?({new_ax, new_ay}, lenx, leny) do
          {:halt, acc}
        else
          {:cont, {{new_ax, new_ay}, [{new_ax, new_ay} | acc]}}
        end
      end)

    right_antinodes =
      Enum.reduce_while(0..lenx, {a2, []}, fn _i, {{ax, ay}, acc} ->
        {new_ax, new_ay} = {ax + diffx, ay + diffy}
        if is_oob?({new_ax, new_ay}, lenx, leny) do
          {:halt, acc}
        else
          {:cont, {{new_ax, new_ay}, [{new_ax, new_ay} | acc]}}
        end
      end)

    left_antinodes ++ right_antinodes ++ [c1, c2]
  end

  def is_oob?({ax, ay}, lenx, leny) do
    xoob = ax > lenx or ax < 0
    yoob = ay > leny or ay < 0

    xoob or yoob
  end

  def find_dimensions(coords) do
    {{lenx, _}, _} = Enum.max_by(coords, fn {{x, _y}, _} -> x end)
    {{_, leny}, _} = Enum.max_by(coords, fn {{_x, y}, _} -> y end)


    {lenx, leny}
  end

  defp print_coords(coords, {lenx, leny}) do
    str = 
      Enum.reduce(0..lenx, "", fn i, acc ->
        Enum.reduce(0..leny, acc, fn j, in_acc ->
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

Day8.part1(coords)
Day8.part2(coords)
  
