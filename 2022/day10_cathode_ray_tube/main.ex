defmodule Day10CathodeRayTube do
  @moduledoc """
  """

  def run(file) do
    {cycles_and_values, final_x_reg} =
      file
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.flat_map(&parse_command/1)
      |> Enum.with_index(1)
      |> Enum.reduce({[], 1}, &execute_command/2)

    IO.inspect(final_x_reg, label: "final_x_reg")

    cycles_and_values
    |> Enum.reverse()
    |> fill_in_missing()
    |> print_execuction()
    |> calculate_signal_strength()
  end

  defp parse_command("noop"), do: [:noop]
  defp parse_command("addx " <> n) do
    [
      {:addx1, String.to_integer(n)},
      {:addx2, String.to_integer(n)}
    ]
  end

  defp execute_command({:noop, cycle_num}, {acc, x_reg}) do
    {[{cycle_num, x_reg} | acc], x_reg}
  end

  defp execute_command({{:addx1, _val}, cycle_num}, {acc, x_reg}) do
    {[{cycle_num, x_reg} | acc], x_reg}
  end

  defp execute_command({{:addx2, val}, cycle_num}, {acc, x_reg}) do
    x_reg_new = x_reg + val
    {[{cycle_num+1, x_reg_new} | acc], x_reg_new}
  end

  defp calculate_signal_strength(cycles_and_values) do
    # for test2 file
    if length(cycles_and_values) <= 10 do
      IO.puts("not long enough list to calculate signal strength")
    else
      cycles = [20, 60, 100, 140, 180, 220]

      Enum.reduce(cycles, 0, fn cycle, acc ->
        {_, x_val} = Enum.find(cycles_and_values, fn {k, _v} -> k == cycle end)

        IO.puts("#{cycle}th cycle, x_reg=#{x_val}, #{cycle}*#{x_val}=#{cycle*x_val}")

        acc + (x_val * cycle)
      end)
      |> IO.inspect(label: "sum of signal strengths")
    end
  end

  def fill_in_missing(cycles_and_values) do
    cycles_and_values
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {{cycle, value}, 0} ->
        [{cycle, value}]

      {{cycle, value}, idx} ->
        {prev_cycle, prev_value} = Enum.at(cycles_and_values, idx-1)

        if prev_cycle == cycle-1 do
          [{cycle, value}]
        else
          diff = cycle - prev_cycle

          if diff == 0 do
            [{cycle, value}]
          else
            diff_list = Enum.to_list(1..diff-1)

            missing_entries =
              for diff_idx <- diff_list do
                {cycle - diff_idx, prev_value}
              end

            missing_entries ++ [{cycle, value}]
          end
        end
    end)
  end

  defp print_execuction(cycles_and_values) do
    for {cycle_num, x_reg} <- cycles_and_values do
      IO.puts("during #{cycle_num} cycle, x_reg was #{x_reg}")
    end

    cycles_and_values
  end
end

Day10CathodeRayTube.run("input")
