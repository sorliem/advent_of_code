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

        
        case Enum.reduce_while(report, {0, 0, 0, nil}, &is_report_safe?/2) do
          {:idx, _} -> acc
          {_res, _, _, _} -> acc + 1
        end
      end)
      

    IO.inspect(ans, label: "part1 num reports safe")
  end

  defp is_report_safe?(level, {acc, idx, last_diff, nil}) do
    {:cont, {acc, idx, last_diff, level}}
  end

  defp is_report_safe?(level, {_acc, idx, last_diff, last_level}) do
    absdiff = abs(level - last_level)
    # IO.inspect(absdiff, label: "absdiff")
    diff_ok? = absdiff >=1 and absdiff <= 3

    diff = level - last_level
    # IO.inspect({diff, last_diff}, label: "{diff, last_diff}")

    monotonic? = (diff > 0 and last_diff >= 0) or (diff < 0 and last_diff <= 0)
    # IO.inspect(monotonic?, label: "monotonic?")

    if diff_ok? and monotonic? do
      {:cont, {1, idx+1, diff, level}}
    else
      # IO.inspect({diff_ok?, monotonic?}, label: "{diff_ok?, monotonic?} NOT OK")
      {:halt, {:idx, idx+1}}
    end
  end

  def part2(file) do
    ans = 
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.map(fn s -> 
        String.split(s, " ", trim: true) 
        |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.reduce(0, fn report, acc ->
        # IO.inspect(report, label: "report")
        IO.puts("")

        Enum.reduce_while(report, {0, 0, 0, nil}, fn level, {_in_acc, idx_outer, last_diff, last_level} = acc ->
          case is_report_safe?(level, acc) do
            {:halt, {:idx, idx}} ->
              IO.inspect({report, idx}, label: "report not safe on first pass at idx")
              new_report = Enum.slice(report, 0, idx) ++ Enum.slice(report, idx+1, length(report) - 1)
              IO.inspect(new_report, label: "new_report")

              # IO.inspect(acc, label: "acc before second pass")

              case Enum.reduce_while(new_report, {0, 0, 0, nil}, &is_report_safe?/2) do
                {:idx, _} -> 
                  IO.inspect(new_report, label: "new_report is STILL BAD!")
                  {:halt, 0}

                _acc -> 
                  IO.inspect(new_report, label: "new_report is VALID!")
                  {:cont, {1, idx_outer, last_diff, last_level}}
              end

            {:cont, {_, idx_inner, last_diff, last_level}} -> 
              IO.inspect(report, label: "report safe so far!")
              {:cont, {1, idx_inner, last_diff, last_level}}
          end
        end)
        |> case do 
          {res, _, _, _} -> 
            # IO.inspect(res+acc, label: "res+acc good case")
            res + acc

          res -> 
            # IO.inspect(res+acc, label: "res bad case")
            res + acc
        end
        |> IO.inspect(label: "RUNNING TOTAL OF GOOD REPORTS")
      end)

    IO.inspect(ans, label: "part2 num reports safe")
  end
end


file = "input"
Day2.part1(file)
Day2.part2(file)
