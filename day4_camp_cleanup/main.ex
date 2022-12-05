

defmodule Day4CampCleanup do
  @moduledoc """
  """

  def run(file) do
    pairs =
      File.read!(file)
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(&to_pairs/1)

    pairs
    |> Enum.reduce(0, &fully_contains?/2)
    |> IO.inspect(label: "part1 fully contains count")

    pairs
    |> Enum.reduce(0, &any_overlap?/2)
    |> IO.inspect(label: "pairs with any overlap")
  end

  defp to_pairs(line) do
    [p1, p2] = String.split(line, ",", parts: 2)
    [lp1, hp1] = String.split(p1, "-", parts: 2)
    [lp2, hp2] = String.split(p2, "-", parts: 2)

    [l1, h1, l2, h2] = Enum.map([lp1, hp1, lp2, hp2], &String.to_integer/1)

    if h2 >= h1 do
      # make sure it is "sorted" with pair with biggest high num on the rhs
      {{l1, h1}, {l2, h2}}
    else
      {{l2, h2}, {l1, h1}}
    end
  end

  def fully_contains?({{l, h}, {l, h}}, acc) do
    # pair is exact same
    acc + 1
  end

  def fully_contains?({{l1, h1}, {l2, h2}}, acc) when h2 >= h1 and l2 <= l1 do
    acc + 1
  end

  def fully_contains?({{l1, h1}, {l2, h2}}, acc) when h1 >= h2 and l1 <= l2 do
    acc + 1
  end

  def fully_contains?(_, acc), do: acc

  def any_overlap?({{_l1, h1}, {l2, _h2}}, acc) when h1 >= l2 do
    acc + 1
  end

  def any_overlap?(_, acc), do: acc
end

# prev wrong answers: 496, 556
Day4CampCleanup.run("input")
