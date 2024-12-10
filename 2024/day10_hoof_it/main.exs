defmodule Day10 do
  @moduledoc """
  Day10: hoof it
  """

  def part1(coords) do
    print_coords(coords)
    trailheads =
      Enum.flat_map(coords, fn 
        {coord, 0} -> [coord];
        _ -> []
      end)
    # |> IO.inspect(label: "trailheads")

    Enum.map(trailheads, &score_trailhead(&1, coords))
    |> Enum.sum()
    |> IO.inspect(label: "part1 answer")
  end

  def score_trailhead({x, y}, coords) do
    find_summits({x, y}, coords)
    |> List.flatten()
    |> Enum.uniq()    # COMMENT THIS LINE OUT TO GET ANSWER TO PART 2!
    |> length()
  end

  def find_summits({x, y}, coords) do 
    find_summits({x, y}, coords, 0)
  end

  def find_summits({x, y}, coords, 8) do
    dirs = [
      {:left, {x-1, y}, Map.get(coords, {x-1, y})},
      {:right, {x+1, y}, Map.get(coords, {x+1, y})},
      {:up, {x, y-1}, Map.get(coords, {x, y-1})},
      {:down, {x, y+1}, Map.get(coords, {x, y+1})}
    ]

    Enum.filter(dirs, fn 
      {_dir, _coord, nil} -> false
      {_dir, _coord, "."} -> false
      {_dir, _coord, elev} -> elev == 9
    end)
    |> Enum.map(fn {_dir, coord, _elev} -> coord end)
  end

  def find_summits({x, y}, coords, cur_elev) do 
    left = Map.get(coords, {x-1, y})
    right = Map.get(coords, {x+1, y})
    up = Map.get(coords, {x, y-1})
    down = Map.get(coords, {x, y+1})

    on_map = Enum.filter([{:left, left}, {:right, right}, {:up, up}, {:down, down}], fn
      {_dir, nil} -> false
      {_dir, "."} -> false
      {_dir, elev} -> elev == cur_elev + 1
    end)

    Enum.reduce(on_map, [], fn 
      {:left, _left}, acc -> [find_summits({x-1, y}, coords, cur_elev + 1) | acc]
      {:right, _right}, acc -> [find_summits({x+1, y}, coords, cur_elev + 1) | acc]
      {:up, _up}, acc -> [find_summits({x, y-1}, coords, cur_elev + 1) | acc]
      {:down, _down}, acc -> [find_summits({x, y+1}, coords, cur_elev + 1) | acc]
    end)
  end

  defp print_coords(coords) do
    IO.puts("Map:")
    keys = Map.keys(coords)
    {max_x, _} = Enum.max_by(keys, fn {x, _y} -> x end)
    {_, max_y} = Enum.max_by(keys, fn {_x, y} -> y end)

    str = 
      Enum.reduce(0..max_x, "", fn i, acc ->
        Enum.reduce_while(0..max_y, acc, fn j, in_acc ->
          if coord = Map.get(coords, {i, j}) do
            {:cont, in_acc <> "#{coord}"}
          else 
            {:halt, in_acc}
          end
        end)
        |> Kernel.<>("\n")
      end)

    IO.puts(str)
  end

end

file = "input"

coords = 
  File.read!(file)
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.with_index()
  |> Enum.reduce(%{}, fn {row, x}, acc -> 
    String.split(row, "", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(acc, fn 
      {".", y}, in_acc ->
        Map.put(in_acc, {x, y}, ".")
      {c, y}, in_acc ->
        Map.put(in_acc, {x, y}, String.to_integer(c))
    end)
  end)

Day10.part1(coords)
  
