

defmodule Day4CampCleanup do
  @moduledoc """
  """

  def run(file) do
    File.read!(file)
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(&to_pairs/1)
    |> Enum.reduce(0, &fully_contains?/2)
    |> IO.inspect()
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

  # 2-4,6-8
  # 2-3,4-5
  # 5-7,7-9
  # 2-8,3-7  <
  # 6-6,4-6  <
  # 2-6,4-8
  def fully_contains?({{l, h}, {l, h}} = pair, acc) do
    IO.inspect(pair, label: "pair is exact same")
    acc + 2
  end

  def fully_contains?({{l1, h1}, {l2, h2}} = pair, acc) when h2 >= h1 and l2 <= l1 do
    # IO.inspect(pair, label: "pair that fully contains")
    acc + 1
  end

  def fully_contains?({{l1, h1}, {l2, h2}} = pair, acc) when h1 >= h2 and l1 <= l2 do
    # IO.inspect(pair, label: "pair that fully contains")
    acc + 1
  end

  def fully_contains?(_, acc), do: acc
end

# prev wrong answers: 496, 556
Day4CampCleanup.run("input")
