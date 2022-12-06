

defmodule Day5SupplyStacks do
  @moduledoc """
  """

  def run(file) do
    [stacks_raw, moveset] =
      File.read!(file)
      |> String.split("\n\n", trim: true)

    stacks_raw
    |> construct_stacks()
    |> IO.inspect(label: "construct_stacks")
    |> move_containers(moveset)
    |> top_stacks()
    |> IO.inspect(label: "top letter across stacks")
  end

  defp move_containers(stacks, moveset) do
    stacks
  end

  defp top_stacks(stacks) do
    "TODO"
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
end

Day5SupplyStacks.run("input.test")
