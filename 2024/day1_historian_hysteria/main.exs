defmodule Day1 do
  @moduledoc """
  Day 1: Historian Hysteria
  """

  def part1(file) do
    ans = 
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.map(fn s -> 
        [a, b] = String.split(s, "   ", trim: true) 
        {String.to_integer(a), String.to_integer(b)}
      end)
      |> Enum.reduce({[], []}, fn {a, b}, {l, r} -> 
        {l ++ [a], r ++ [b]}
      end)
      |> then(fn {l, r} -> Enum.zip(Enum.sort(l), Enum.sort(r)) end)
      |> Enum.reduce(0, fn {l, r}, acc ->
        acc + abs(l - r)
      end)

    IO.inspect(ans, label: "part1 answer")
  end

  def part2(file) do
    ans = 
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.map(fn s -> 
        [a, b] = String.split(s, "   ", trim: true) 
        {String.to_integer(a), String.to_integer(b)}
      end)
      |> Enum.reduce({[], []}, fn {a, b}, {l, r} -> 
        {l ++ [a], r ++ [b]}
      end)
      |> then(fn {l, r} -> 
        freq = Enum.frequencies(r)

        Enum.reduce(l, 0, fn l_num, acc ->
          l_freq = Map.get(freq, l_num, 0)
          acc + (l_num * l_freq)
        end)
      end)

    IO.inspect(ans, label: "part2 answer")
  end
end




file = "input"
Day1.part1(file)
Day1.part2(file)
