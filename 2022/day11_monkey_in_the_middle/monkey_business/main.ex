defmodule MonkeyBusiness do
  @moduledoc """
  """

  defmodule Monkey do
    defstruct [
      id: nil,
      items: :queue.new(),
      inspect_count: 0,
      operation_fn: nil,
      test_fn: nil,
      test_true_id: nil,
      test_false_id: nil
    ]
  end

  def build_monkeys(file) do
    monkeys =
      file
      |> File.read!()
      |> String.split("\n\n", trim: true)
      |> Enum.map(&to_monkey/1)
      |> IO.inspect(label: "monkeys")

    # pids =
    #   for monkey <- monkeys do
    #     MonkeyServer.start_link(monkey: monkey)
    #   end
    # |> IO.inspect(label: "pids")

  end

  defp play_game(monkeys) do
    Enum.reduce(1..20, monkeys, fn _i, monkeys ->
      for monkey <- monkeys do
        q_len = :queue.len(monkey.items)
        Enum.reduce_while(0..q_len, monkey, fn _i, cur_monkey ->
          # {:cont, m

        end)
      end
    end)
  end

  defp to_monkey(lines) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.reduce(%Monkey{}, fn line, m ->
      trimmed = String.trim(line)
      case get_prop(trimmed) do
        {:id, id} ->
          %Monkey{m | id: id}

        {:items, items} ->
          starting_items =
            Enum.reduce(items, m.items, fn item, queue ->
              :queue.in(item, queue)
            end)

          %Monkey{m | items: starting_items}

        {:operation_fn, fun} ->
          %Monkey{m | operation_fn: fun}

        {:test_fn, fun} ->
          %Monkey{m | test_fn: fun}

        {:test_true_id, id} ->
          %Monkey{m | test_true_id: id}

        {:test_false_id, id} ->
          %Monkey{m | test_false_id: id}
      end
    end)
  end

  defp get_prop(<<"Monkey ", i::binary-size(1), ":">>) do
    {:id, String.to_integer(i)}
  end

  defp get_prop(<<"Starting items: ", rest::binary>>) do
    items =
      rest
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)

    {:items, items}
  end

  defp get_prop(<<"Operation: new = old ", operation::binary-size(1), " ", rhs::binary>>) do
    fun =
      case {operation, rhs} do
        {"*", "old"} ->
          fn old -> old * old end

        {"*", int} ->
          n = String.to_integer(int)
          fn old -> old * n end

        {"+", "old"} ->
          fn old -> old + old end

        {"+", int} ->
          n = String.to_integer(int)
          fn old -> old + n end
      end

    {:operation_fn, fun}
  end

  defp get_prop(<<"Test: divisible by ", i::binary>>) do
    n = String.to_integer(i)
    fun = fn worry_level -> rem(worry_level, n) == 0 end

    {:test_fn, fun}
  end

  defp get_prop(<<"If true: throw to monkey ", i::binary>>) do
    n = String.to_integer(i)

    {:test_true_id, n}
  end

  defp get_prop(<<"If false: throw to monkey ", i::binary>>) do
    n = String.to_integer(i)

    {:test_false_id, n}
  end

  defp calculate_monkey_business(_monkeys) do
    IO.puts("TODO: calculate monkey business")
  end
end

# MonkeyBusiness.run("input.test")
