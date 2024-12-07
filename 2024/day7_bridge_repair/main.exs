defmodule Day7 do
  @moduledoc """
  Day7: Bridge Repair
  """

  def part1(equations) do 
    equations
    |> Stream.map(fn {total, vals} ->
      ops_for_len = gen_ops(length(vals))
      [hd | tail] = vals
      
      equations = 
        Enum.map(ops_for_len, fn opstr ->
          oplist = String.split(opstr, "", trim: true)
          inter = 
            Enum.zip(oplist, tail)
            |> Enum.flat_map(fn {op, val} -> [op, val] end)

          [hd | inter]
        end)

      {total, equations}
    end)
    |> Stream.flat_map(fn {total, equations} ->
      if Enum.any?(equations, fn equation -> sum(equation) == total end) do
        [total]
      else
        []
      end
    end)
    |> Enum.sum()
    |> IO.inspect(label: "part1 answer")
  end

  def sum(equation) do 
    {sum, _} = 
      Enum.reduce(equation, {0, nil}, fn 
        int, {_acc, nil} when is_integer(int) -> {int, nil}
        "+", {acc, nil} -> {acc, "+"}
        "*", {acc, nil} -> {acc, "*"}
        "|", {acc, nil} -> {acc, "|"}
        int, {acc, "+"} -> {acc + int, nil} 
        int, {acc, "*"} -> {acc * int, nil} 
        int, {acc, "|"} -> {String.to_integer("#{acc}#{int}"), nil} 
      end)

    sum
  end

  def gen_ops(n) do
    start_ops = ["*", "+"]

    Enum.map(start_ops, fn base ->
      gen_op(base, n-1, [])
    end)
    |> List.flatten()
    |> Enum.filter(fn op -> String.length(op) == n end) |> Enum.uniq()
    # |> IO.inspect(label: "OPS")
  end
  
  defp gen_op(_base, 0, bases), do: bases
  defp gen_op(base, n, bases) do
    base_a = base <> "*"
    base_b = base <> "+"
    new_bases = [base_a | [base_b | bases]]

    [gen_op(base_a, n-1, new_bases) | [gen_op(base_b, n-1, new_bases)]]
  end

  def gen_op_map(n \\ 12) do
    2..n
    |> Enum.into(%{}, fn i -> 
      {i, gen_ops2(i)}
    end)
  end

  def part2(equations) do
    op_map = gen_op_map()

    equations
    # |> Enum.take(2)
    |> Enum.map(fn {total, vals} ->
      ops_for_len = Map.get(op_map, length(vals))

      [hd | tail] = vals
      
      equations = 
        Enum.map(ops_for_len, fn opstr ->
          oplist = String.split(opstr, "", trim: true)
          inter = 
            Enum.zip(oplist, tail)
            |> Enum.flat_map(fn {op, val} -> [op, val] end)

            [hd | inter]
        end)

      {total, equations}
    end)
    |> Enum.flat_map(fn {total, equations} ->
      if Enum.any?(equations, fn equation -> sum(equation) == total end) do
        [total]
      else
        []
      end
    end)
    |> Enum.sum()
    |> IO.inspect(label: "part2 answer")
  end

  def gen_ops2(n) do
    start_ops = ["*", "+", "|"]

    Enum.map(start_ops, fn base ->
      gen_op2(base, n-1, [])
    end)
    |> List.flatten()
    |> Enum.filter(fn op -> String.length(op) == n end) |> Enum.uniq()
  end
  
  defp gen_op2(_base, 0, bases), do: bases
  defp gen_op2(base, n, bases) do
    base_a = base <> "*"
    base_b = base <> "+"
    base_c = base <> "|"
    new_bases = [base_a | [base_b | [base_c | [ bases ]]]]
    
    [gen_op2(base_a, n-1, new_bases) | [ gen_op2(base_b, n-1, new_bases) | [gen_op2(base_c, n-1, new_bases)]]]
  end
end

file = "input"

equations = 
  file
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [total, values] = String.split(line, ":", parts: 2, trim: true)

    nums = 
      values
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    {String.to_integer(total), nums}
  end)
  # |> IO.inspect(label: "equations")

Day7.part1(equations)
Day7.part2(equations)
  
