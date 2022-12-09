defmodule Day8TreetopTreeHouse do
  @moduledoc """
  """

  def run(file) do
    file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.reduce([], &build_forest/2)
    |> Enum.reverse()
    |> mark_visible()
    |> count_visible()
  end

  defp mark_visible(forest) do
    forest
    |> Enum.with_index()
    |> Enum.map(fn {row, row_idx} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {{tree_height, _visible}, col_idx} ->
        vis_rowwise? = surrounding_row_visible?(forest, row_idx, col_idx)
        vis_colwise? = surrounding_col_visible?(forest, row_idx, col_idx)

        if vis_rowwise? or vis_colwise? do
          # current tree height is visible from at least one direction
          {tree_height, true}
        else
          {tree_height, false}
        end
      end)
    end)
  end

  defp surrounding_col_visible?(forest, row_idx, col_idx) do
    row = Enum.at(forest, row_idx)
    {inspected_val, _vis} = Enum.at(row, col_idx)

    col =
      Enum.reduce(forest, [], fn row, acc ->
        col_val = Enum.at(row, col_idx)
        [col_val | acc]
      end)
      |> Enum.reverse()

    {top, [{_inspected_val, _} | bottom]} = Enum.split(col, row_idx)

    case {top, bottom} do
      {[], _} ->
        # top edge, is visible
        true

      {_, []} ->
        # bottom edge, is visible
        true

      {l, r} ->
        top_all_less = Enum.all?(l, fn {i, _vis} -> i < inspected_val end)
        bottom_all_less = Enum.all?(r, fn {i, _vis} -> i < inspected_val end)

        top_all_less or bottom_all_less
        (top_all_less or bottom_all_less)
    end
  end

  defp surrounding_row_visible?(forest, row_idx, col_idx) do
    row = Enum.at(forest, row_idx)
    {inspected_val, _} = Enum.at(row, col_idx)

    {left, [{_inspected_val, _} | right]} = Enum.split(row, col_idx)

    case {left, right} do
      {[], _} ->
        # left edge, is visible
        true

      {_, []} ->
        # right edge, is visible
        true

      {l, r} ->
        left_all_less = Enum.all?(l, fn {i, _vis} -> i < inspected_val end)
        right_all_less = Enum.all?(r, fn {i, _vis} -> i < inspected_val end)


        left_all_less or right_all_less
    end
  end

  defp build_forest(line, acc) do
    cols =
      line
      |> String.split("", trim: true)
      |> Enum.map(fn height -> {String.to_integer(height), false} end)

    [cols | acc]
  end

  defp count_visible(forest) do
    forest
    |> List.flatten()
    |> Enum.count(fn {_height, visible} -> visible end)
    |> IO.inspect(label: "num trees visible")
  end
end

Day8TreetopTreeHouse.run("input")
