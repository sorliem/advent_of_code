defmodule Day3 do
  @moduledoc """
  Day 3: Mull it over
  """

  def part1(memory) do
    scans = Regex.scan(~r/mul\(\d*,\d*\)/, memory)

    Enum.reduce(scans, 0, fn ["mul" <> pair], acc ->
      [n1, n2] = 
        pair 
        |> String.trim_leading("(") 
        |> String.trim_trailing(")")
        |> String.split(",", parts: 2) 
        |> Enum.map(&String.to_integer/1)

      acc + (n1 * n2)
    end)
    |> IO.inspect(label: "part1 total")
  end

  def part2(memory) do
    scans = Regex.scan(~r/mul\(\d*,\d*\)|don't\(\)|do\(\)/, memory)

    Enum.reduce(scans, {_total = 0, _instructions_enabled = true}, fn 
      ["don" <> _], {acc, false} ->
        # already disabled, continue
        {acc, false}

      ["don" <> _], {acc, true} ->
        # enabled to disabled
        {acc, false}

      ["do" <> _], {acc, false} ->
        # disabled to enabled
        {acc, true}

      ["do" <> _], {acc, true} ->
        # already enabled, continue
        {acc, true}

      ["mul" <> _], {acc, false} -> 
        # multiply command but adding is disbled
        {acc, false}

      ["mul" <> pair], {acc, true} ->
        [n1, n2] = 
          pair 
          |> String.trim_leading("(") 
          |> String.trim_trailing(")")
          |> String.split(",", parts: 2) 
          |> Enum.map(&String.to_integer/1)

        {acc + (n1 * n2), true}
    end)
    |> IO.inspect(label: "part2 total")
  end
end

file = "input"

corrupt_memory = 
  File.read!(file)
  |> String.split("\n", trim: true)
  |> Enum.join("")

Day3.part1(corrupt_memory)
Day3.part2(corrupt_memory)
