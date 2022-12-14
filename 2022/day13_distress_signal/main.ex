defmodule Day13DistressSignal do
  @moduledoc """
  """

  def run(file) do
    file
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn pair -> String.split(pair, "\n", parts: 2) end)
    |> Enum.map(&parse_to_list/1)
    |> Enum.with_index(1)
    |> Enum.reduce(0, &count_correct_order/2)
    |> IO.inspect(label: "sum of idxs with correct order")
  end

  defp count_correct_order({[left, right], idx}, acc) do
    correct_order = check(left, right)

    if correct_order do
      acc + idx
    else
      acc
    end
  end

  # left list ran out first
  defp check([], [_ | _]), do: true
  defp check([_ | _], []), do: false
  defp check([], []), do: :cont

  defp check(l, r) when is_integer(l) and is_list(r) do
    check([l], r)
  end

  defp check(l, r) when is_list(l) and is_integer(r) do
    check(l, [r])
  end

  defp check(l, r) when is_integer(l) and is_integer(r) do
    cond do
      l < r -> true
      l == r -> :cont
      l > r -> false
    end
  end

  defp check(n, n) when is_integer(n) do
    :cont
  end

  defp check([left_head | left_tail], [right_head | right_tail]) do
    case check(left_head, right_head) do
      true ->
        true

      false -> false

      :cont ->
        check(left_tail, right_tail)
    end
  end

  defp parse_to_list([left, right]) do
    for part <- [left, right] do
      expr = "Foo=" <> part <> "."

      expr
      |> String.to_charlist()
      |> parse_to_elixir_list()
    end
  end

  defp parse_to_elixir_list(l) do
    {:ok, tokens, _} = :erl_scan.string(l)
    {:ok, parsed} = :erl_parse.parse_exprs(tokens)
    {:value, v, _} = :erl_eval.exprs(parsed, [])

    v
  end
end

Day13DistressSignal.run("input")
