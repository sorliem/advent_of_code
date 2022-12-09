defmodule Test do
  @moduledoc """
  """

  @matrix [
    [3,0,3],
    [2,7,5],
    [6,5,3]
  ]

  @matrix2 [
    [3,0,3,7,3],
    [2,5,5,1,2],
    [6,5,3,3,2],
    [3,3,5,4,9],
    [3,5,3,9,0]
  ]

  def get_col(n) do
      Enum.reduce(@matrix2, [], fn row, acc ->
        col_val = Enum.at(row, n)
        [col_val | acc]
      end)
      |> Enum.reverse()
  end

  def get_surrounding_col(row_idx, col_idx) do
    row = Enum.at(@matrix, row_idx)
    inspected_val = Enum.at(row, col_idx)
    IO.inspect(inspected_val, label: "inspected_val")

    col =
      Enum.reduce(@matrix, [], fn row, acc ->
        col_val = Enum.at(row, col_idx)
        [col_val | acc]
      end)
      |> Enum.reverse()

    {top, [_cross | bottom]} = Enum.split(col, row_idx)

    top_all_less = Enum.all?(top, fn i -> i < inspected_val end)
    bottom_all_less = Enum.all?(bottom, fn i -> i < inspected_val end)

    (top_all_less or bottom_all_less) |> IO.inspect(label: "top or bottom all less around #{inspected_val}?")

    [top: top, bottom: bottom, inspected_val: inspected_val]
  end
end
