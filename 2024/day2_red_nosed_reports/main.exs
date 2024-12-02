defmodule Day2 do
  @moduledoc """
  Day 2: Red Nosed Reports
  """

  def part1(file) do
    ans = 
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.map(fn s -> 
        String.split(s, " ", trim: true) 
        |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.reduce(0, fn report, acc ->
        # IO.inspect(report, label: "report")

        {res, _, _} = 
          Enum.reduce_while(report, {0, 0, nil}, &is_report_safe?/2)

        res + acc
      end)
      

    IO.inspect(ans, label: "part1 num reports safe")
  end

  defp is_report_safe?(level, {acc, last_diff, nil}) do
    {:cont, {acc, last_diff, level}}
  end

  defp is_report_safe?(level, {acc, last_diff, last_level}) do
    absdiff = abs(level - last_level)
    # IO.inspect(absdiff, label: "absdiff")
    diff_ok? = absdiff >=1 and absdiff <= 3

    diff = level - last_level
    # IO.inspect({diff, last_diff}, label: "{diff, last_diff}")

    monotonic? = (diff > 0 and last_diff >= 0) or (diff < 0 and last_diff <= 0)
    # IO.inspect(monotonic?, label: "monotonic?")

    if diff_ok? and monotonic? do
      {:cont, {1, diff, level}}
    else
      # IO.inspect({diff_ok?, monotonic?}, label: "{diff_ok?, monotonic?} NOT OK")
      {:halt, {0, diff, level}}
    end
  end

  def part2(_file) do
  end
end


file = "input"
Day2.part1(file)
Day2.part2(file)
