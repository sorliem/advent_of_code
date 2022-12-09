defmodule Day8TreetopTreeHouse do
  @moduledoc """
  """

  def run(file) do
    marked_tree =
      file
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.reduce([], &build_forest/2)
      |> Enum.reverse()
      |> mark_visible()
      # |> IO.inspect(label: "marked tree")

    count_visible(marked_tree)
    highest_scenic_point(marked_tree)
  end

  defp mark_visible(forest) do
    forest
    |> Enum.with_index()
    |> Enum.map(fn {row, row_idx} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {{tree_height, _visible}, col_idx} ->
        {vis_rowwise?, {s1, s2}} = surrounding_row_visible?(forest, row_idx, col_idx)
        {vis_colwise?, {s3, s4}} = surrounding_col_visible?(forest, row_idx, col_idx)
        scenic_score = s1 * s2 * s3 * s4
        # IO.inspect({s1, s2, s3, s4, scenic_score}, label: "{s1, s2, s3, s4, scenic_score} for #{tree_height} at #{row_idx},#{col_idx}")

        if vis_rowwise? or vis_colwise? do
          # current tree height is visible from at least one direction
          {tree_height, true, scenic_score}
        else
          {tree_height, false, scenic_score}
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

    scores =
      {score_view(Enum.reverse(top), inspected_val), score_view(bottom, inspected_val)}

    case {top, bottom} do
      {[], _} ->
        # top edge, is visible
        {true, scores}

      {_, []} ->
        # bottom edge, is visible
        {true, scores}

      {l, r} ->
        top_all_less = Enum.all?(l, fn {i, _vis} -> i < inspected_val end)
        bottom_all_less = Enum.all?(r, fn {i, _vis} -> i < inspected_val end)

        {top_all_less or bottom_all_less, scores}
    end
  end

  defp surrounding_row_visible?(forest, row_idx, col_idx) do
    row = Enum.at(forest, row_idx)
    {inspected_val, _} = Enum.at(row, col_idx)

    {left, [{_inspected_val, _} | right]} = Enum.split(row, col_idx)

    scores =
      {score_view(Enum.reverse(left), inspected_val), score_view(right, inspected_val)}

    case {left, right} do
      {[], _} ->
        # left edge, is visible
        {true, scores}

      {_, []} ->
        # right edge, is visible
        {true, scores}

      {l, r} ->
        left_all_less = Enum.all?(l, fn {i, _vis} -> i < inspected_val end)
        right_all_less = Enum.all?(r, fn {i, _vis} -> i < inspected_val end)

        {left_all_less or right_all_less, scores}
    end
  end

  defp score_view([], _tree_height), do: 0
  defp score_view(trees, tree_height) do
    Enum.reduce_while(trees, 0, fn {cur_tree, _}, acc ->
      cond do
        cur_tree < tree_height ->
          {:cont, acc + 1}

        cur_tree == tree_height ->
          {:halt, acc + 1}

        true ->
          {:halt, acc + 1}
      end
    end)
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
    |> Enum.count(fn {_height, visible, _scenic_score} -> visible end)
    |> IO.inspect(label: "num trees visible")
  end

  defp highest_scenic_point(forest) do
    forest
    |> List.flatten()
    |> Enum.max_by(fn {_height, _visible, scenic_score} -> scenic_score end)
    |> elem(2)
    |> IO.inspect(label: "highest scenic point")
  end
end

Day8TreetopTreeHouse.run("input")
