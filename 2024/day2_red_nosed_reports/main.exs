defmodule Day2 do
  @moduledoc """
  Day 2: Red Nosed Reports
  """

  def part1(reports) do
    ans = 
      Enum.reduce(reports, 0, fn report, acc ->
        case Enum.reduce_while(report, {0, 0, 0, nil}, &is_report_safe?/2) do
          {:idx, _} -> acc
          {_res, _, _, _} -> acc + 1
        end
      end)

    IO.inspect(ans, label: "part1 num reports safe")
  end

  def part2(reports) do
    ans = 
      Enum.reduce(reports, 0, fn report, acc ->
        if is_report_safe2?(report) do
          acc+1
        else
          acc
        end
      end)

    IO.inspect(ans, label: "part2 num reports safe")
  end

  defp is_report_safe?(level, {acc, idx, last_diff, nil}) do
    {:cont, {acc, idx, last_diff, level}}
  end

  defp is_report_safe?(level, {_acc, idx, last_diff, last_level}) do
    absdiff = abs(level - last_level)
    diff_ok? = absdiff >=1 and absdiff <= 3
    diff = level - last_level
    monotonic? = (diff > 0 and last_diff >= 0) or (diff < 0 and last_diff <= 0)

    if diff_ok? and monotonic? do
      {:cont, {1, idx+1, diff, level}}
    else
      {:halt, {:idx, idx+1}}
    end
  end

  def is_report_safe2?(report) do
    orig_report_len = length(report)

    safe_fn = fn report2 ->
      report_len = length(report2)
      report_w_index = Enum.with_index(report2)

      Enum.reduce_while(report_w_index, {nil, 0}, fn
        {level, 0}, {nil, last_diff}  ->
          {:cont, {level, last_diff}}

        {level, idx}, {_last_level, last_diff}  ->
          if idx == report_len do
            # last element, return true
            {:cont, {level, last_diff}}
          else
            l1 = Enum.at(report2, idx-1)
            l2 = Enum.at(report2, idx)

            absdiff = abs(l1 - l2)
            diff_ok? = absdiff >=1 and absdiff <= 3
            diff = l1 - l2
            monotonic? = (diff > 0 and last_diff >= 0) or (diff < 0 and last_diff <= 0)

            if diff_ok? and monotonic? do
              {:cont, {level, diff}}
            else
              {:halt, false}
            end
          end
      end)
      |> case do
        false -> false
        _ -> true
      end
    end

    if safe_fn.(report) do
      true
    else
      # brute force try removing each element
      Enum.any?(0..orig_report_len-1, fn idx ->
        new_report = Enum.slice(report, 0, idx) ++ Enum.slice(report, idx+1, length(report) - 1)
        safe_fn.(new_report)
      end)
    end
  end
end


file = "input"

reports = 
  File.read!(file)
  |> String.split("\n", trim: true)
  |> Enum.map(fn s -> 
    String.split(s, " ", trim: true) 
    |> Enum.map(&String.to_integer/1)
  end)

Day2.part1(reports)
Day2.part2(reports)
