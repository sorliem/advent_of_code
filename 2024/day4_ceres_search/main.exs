defmodule Day4 do
  @moduledoc """
  Day 4: Ceres search
  """

  def part1(word_search) do
    board = 
      word_search
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {letter, j}, acc2 ->
          Map.put(acc2, {i, j}, letter)
        end)
      end)

    Enum.reduce(board, 0, fn 
      {{x, y}, "X"}, acc -> 
         acc + search_for_xmas(board, {x, y})

      {{_x, _y}, _letter}, acc -> 
        acc
    end)
    |> IO.inspect(label: "part1 XMAS found")
  end

  def search_for_xmas(board, coord) do
    searches = 
      for xdir <- -1..1, ydir <- -1..1 do
        if xdir == 0  and ydir == 0 do
          0
        else
          search(board, coord, {xdir, ydir}) 
        end
      end
    
    Enum.sum(searches)
  end

  def search(board, {x, y}, {stepx, stepy}, search_letter \\ "M") do
    {found, _} =
      Enum.reduce_while(1..3, {0, search_letter}, fn i, {_res, sl} ->
        new_coord = {x + (stepx * i), y + (stepy * i)}
        next_letter = Map.get(board, new_coord)
        if next_letter == sl do
          {:cont, {1, next_letter(sl)}}
        else
          {:halt, {0, nil}}
        end
      end)

    found
  end

  def next_letter("X"), do: "M"
  def next_letter("M"), do: "A"
  def next_letter("A"), do: "S"
  def next_letter(_), do: :done

  def part2(word_search) do
    board = 
      word_search
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {letter, j}, acc2 ->
          Map.put(acc2, {i, j}, letter)
        end)
      end)

    Enum.reduce(board, 0, fn 
      {{x, y}, "A"}, acc -> 
         acc + search_for_xmas2(board, {x, y})

      {{_x, _y}, _letter}, acc -> 
        acc
    end)
    |> IO.inspect(label: "part2 X-MAS found")
  end

  defp search_for_xmas2(board, {coordx, coordy}) do
    topleft = Map.get(board, {coordx - 1, coordy - 1})
    botright = Map.get(board, {coordx + 1, coordy + 1})

    topright = Map.get(board, {coordx + 1, coordy - 1})
    botleft = Map.get(board, {coordx - 1, coordy + 1})

    word1 = [topleft, botright] |> Enum.filter(& &1) |> Enum.sort() |> Enum.join("")
    word2 = [topright, botleft] |> Enum.filter(& &1) |> Enum.sort() |> Enum.join("")

    if word1 == "MS" and word2 == "MS" do
      1
    else
      0
    end
  end
end

file = "input"
ws = 
  File.read!(file)
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "", trim: true))

Day4.part1(ws)
Day4.part2(ws)
