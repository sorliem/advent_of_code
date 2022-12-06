defmodule Day5SupplyStacks do
  @moduledoc """
  """

  def run(file) do
    [stacks_raw, moveset] =
      file
      |> File.read!()
      |> String.split("\n\n", trim: true)

    moveset = parse_moveset(moveset)

    stacks_raw
    |> construct_stacks()
    |> move_containers(moveset)
    |> top_stacks()
    |> IO.inspect(label: "top letter across stacks")
  end

  defp parse_moveset(moveset) do
    moveset
    |> String.split("\n")
    |> Enum.flat_map(&parse_line/1)
  end

  defp parse_line(<<"move ", amt::binary-size(1), " from ",  from::binary-size(1), " to ", to::binary-size(1)>>) do
    [{
      String.to_integer(amt),
      String.to_integer(from),
      String.to_integer(to),
    }]
  end

  defp parse_line(<<"move ", amt::binary-size(2), " from ",  from::binary-size(1), " to ", to::binary-size(1)>>) do
    [{
      String.to_integer(amt),
      String.to_integer(from),
      String.to_integer(to),
    }]
  end

  defp parse_line(""), do: []

  defp move_containers(stacks, moveset) do
    Enum.reduce(moveset, stacks, fn {amt, from, to}, stacks ->
      from_idx = int_to_word(from)
      to_idx = int_to_word(to)

      from_stack = Keyword.get(stacks, from_idx)
      {from_remaining, to_be_moved} = Enum.split(from_stack, -amt)

      to_stack = Keyword.get(stacks, to_idx)

      # Part 1, crates are reversed
      # to_stack_final = to_stack ++ Enum.reverse(to_be_moved)

      # Part 2, crates are NOT reversed
      to_stack_final = to_stack ++ to_be_moved

      stacks
      |> Keyword.put(from_idx, from_remaining)
      |> Keyword.put(to_idx, to_stack_final)
    end)
  end

  defp top_stacks(stacks) do
    stacks
    |> Enum.sort_by(fn {idx, _stack} -> word_to_int(idx) end, &Kernel.<=/2)
    |> IO.inspect(label: "sorted final stack")
    |> Enum.reduce("", fn {_idx, stack}, acc ->
      acc <> List.last(stack)
    end)
  end

  defp construct_stacks(stacks_raw) do
    parsed_crate_items =
      stacks_raw
      |> String.graphemes()
      |> Enum.chunk_every(4)
      |> Enum.map(&item/1)

    n_cols = get_n_cols(parsed_crate_items)
    stacks =
      for idx <- 1..n_cols do
        {int_to_word(idx), []}
      end

    {_, stacks} = Enum.reduce(parsed_crate_items, {1, stacks}, &place_crate_on_stack/2)

    stacks
  end

  defp place_crate_on_stack(item, {col_num, stacks}) do
    case item do
      :blank -> {col_num+1, stacks}
      {:crate, crate} ->
        stack = Keyword.fetch!(stacks, int_to_word(col_num))
        new_stack = [crate | stack]
        stacks = Keyword.put(stacks, int_to_word(col_num), new_stack)
        {col_num+1, stacks}

      {:rightmost_crate, crate} ->
        stack = Keyword.fetch!(stacks, int_to_word(col_num))
        new_stack = [crate | stack]
        stacks = Keyword.put(stacks, int_to_word(col_num), new_stack)
        {1, stacks}

      _ ->
        {col_num, stacks}
    end
  end

  defp get_n_cols(chunked) do
    chunked
    |> Enum.reverse()
    |> Enum.reduce(0, fn chunk, acc ->
      case chunk do
        {:col_num, _} -> acc + 1
        _ -> acc
      end
    end)
  end

  defp item([" ", d]) when d != "", do: {:col_num, d}
  defp item([" ", d, " ", " "]) when d != " ", do: {:col_num, d}
  defp item([" ", d, " ", " "]) when d != " ", do: {:col_num, d}
  defp item(["[", n, "]", " "]), do: {:crate, n}
  defp item(["[", n, "]", "\n"]), do: {:rightmost_crate, n}
  defp item([" ", " ", " ", " "]), do: :blank

  # this is dumb
  def int_to_word(int) do
    case int do
      1 -> :one
      2 -> :two
      3 -> :three
      4 -> :four
      5 -> :five
      6 -> :six
      7 -> :seven
      8 -> :eight
      9 -> :nine
    end
  end

  # this is dumb
  def word_to_int(int) do
    case int do
      :one -> 1
      :two -> 2
      :three -> 3
      :four -> 4
      :five -> 5
      :six -> 6
      :seven -> 7
      :eight -> 8
      :nine -> 9
    end
  end
end

Day5SupplyStacks.run("input")
