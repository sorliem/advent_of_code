

defmodule Day3Rucksack do
  @moduledoc """
  """

  def run(file) do
    File.read!(file)
    |> String.split("\n")
    |> Enum.flat_map(&find_common/1)
    |> Enum.reduce(0, &priority/2)
    |> IO.inspect(label: "part 1 priority")

    File.read!(file)
    |> String.split("\n")
    |> Enum.chunk_every(3)
    |> Enum.flat_map(&find_badge/1)
    |> Enum.reduce(0, &priority/2)
    |> IO.inspect(label: "part 2 priority")
  end

  defp find_common(line) do
    len = String.length(line)
    mid = Integer.floor_div(len, 2)
    {left, right} = String.split_at(line, mid)
    s1 = String.split(left, "") |> Enum.reject(& (&1 == "")) |> MapSet.new()
    s2 = String.split(right, "") |> Enum.reject(& (&1 == "")) |> MapSet.new()

    MapSet.intersection(s1, s2)
    |> MapSet.to_list()
    |> List.first()
    |> case do
      nil -> []
      c -> [String.to_charlist(c)]
    end
  end

  def find_badge([e1, e2, e3]) do
    e1 = String.split(e1, "") |> Enum.reject(& (&1 == "")) |> MapSet.new()
    e2 = String.split(e2, "") |> Enum.reject(& (&1 == "")) |> MapSet.new()
    e3 = String.split(e3, "") |> Enum.reject(& (&1 == "")) |> MapSet.new()

    temp = MapSet.intersection(e1, e2)
    badge = MapSet.intersection(temp, e3)

    badge =
      badge
      |> MapSet.to_list()
      |> List.first()
      |> String.to_charlist()

    [badge]
  end

  def find_badge(_), do: []

  def priority([c], acc) when c in ?a..?z do
    acc + (c - 96)
  end

  def priority([c], acc) when c in ?A..?Z do
    acc + (c - 38)
  end
end

Day3Rucksack.run("input")
