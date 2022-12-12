defmodule MonkeyBusiness do
  @moduledoc """
  """

  defmodule Monkey do
    defstruct [
      id: nil,
      items: :queue.new(),
      inspect_count: 0,
      div_n: nil,
      common_mult_n: nil,
      operation_fn: nil,
      test_fn: nil,
      test_true_id: nil,
      test_false_id: nil
    ]
  end

  def build_monkeys(file) do
    file
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(&to_monkey/1)
  end

  def play_game() do
    monkey_pids = get_monkeys()

    IO.puts("\n==== BEFORE GAME ====")
    print_stats(0, monkey_pids)

    rounds = 10_000

    for i <- 1..rounds do
      if rem(i, 20) == 0 do
        IO.puts("\n==== ROUND #{i} ====")
      end

      for {monkey_id, pid} <- monkey_pids do
        ref = make_ref()
        send(pid, {:do_turn, self(), ref})

        receive do
          {:turn_done, ^ref} -> :ok
        end
      end

      # print_stats(i, monkey_pids)
    end

    print_stats(rounds, monkey_pids)
  end

  def print_stats() do
    monkey_pids = get_monkeys()
    print_stats(:end, monkey_pids)
  end

  defp print_stats(i, monkey_pids) do
    IO.puts("")

    inspect_counts =
      Enum.map(monkey_pids, fn {monkey_id, pid} ->
        {items, inspect_count} = GenServer.call(pid, :get_stats)
        items = Enum.map(items, fn item -> "#{item}" end)
        IO.puts("R#{i}Monkey#{monkey_id}: #{inspect items}, inspect_count: #{inspect_count}")

        inspect_count
      end)

    monkey_business =
      inspect_counts
      |> Enum.sort()
      |> Enum.reverse()
      |> Enum.take(2)
      |> Enum.reduce(1, fn i, acc -> i * acc end)

    IO.puts("total monkey business at ROUND #{i}: #{monkey_business}")
  end

  defp get_monkeys() do
    Supervisor.which_children(Elixir.MonkeyBusiness.Supervisor)
    |> Enum.sort_by(fn {id, _, _, _} -> id end)
    |> Enum.flat_map(fn {id, pid, _, _} ->
      if Atom.to_string(id) =~ "MonkeyServer" do
        [{id, pid}]
      else
        []
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

        {:test_fn, fun, n} ->
          %Monkey{m | test_fn: fun, div_n: n}

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
    fun = fn worry_level ->
      # 23 mod trick
      remain = rem(worry_level, 23 * n)

      rem(remain, n) == 0
    end

    {:test_fn, fun, n}
  end

  defp get_prop(<<"If true: throw to monkey ", i::binary>>) do
    n = String.to_integer(i)

    {:test_true_id, n}
  end

  defp get_prop(<<"If false: throw to monkey ", i::binary>>) do
    n = String.to_integer(i)

    {:test_false_id, n}
  end
end
