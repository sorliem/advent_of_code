defmodule Day9RopeBridgePt2 do
  @moduledoc """

  grid:
    |
    |
   ^|
   ||
   y|
    |
   0|________________
    0      x->
  """

  @initial_pos %{
    "H" => {0, 0},
    "1" => {0, 0},
    "2" => {0, 0},
    "3" => {0, 0},
    "4" => {0, 0},
    "5" => {0, 0},
    "6" => {0, 0},
    "7" => {0, 0},
    "8" => {0, 0},
    "9" => {0, 0}
  }

  # DOES NOT WORK. INCOMPLETE.
  def run(file) do
    file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_move/1)
    |> Enum.reduce({@initial_pos, MapSet.new([{0,0}])}, &do_move/2)
    |> count_visted_spaces()
  end

  defp get_tail_for(positions, "9"), do: nil
  defp get_tail_for(positions, pos) do
    if pos == "H" do
      Map.get(positions, "1")
    else
      tail_key = Integer.to_string(String.to_integer(pos) + 1)

      Map.get(positions, tail_key)
    end

  end

  defp do_move({:up, amount}, acc) do
    # increment hy
    Enum.reduce(1..amount, acc, fn _i, {positions, visits} ->
      Enum.reduce(positions, {positions, visits}, fn {name, {hx, hy}}, {i_positions, i_visits} ->
        new_hy = hy + 1
        tail_pos = get_tail_for(i_positions, name)
        if tail_pos do
          distance = euc_distance({hx, new_hy}, {tx, ty})

          cond do
            distance < 2.0  ->
              # kitty corner, tail does not need to move
              {{hx, new_hy}, {tx, ty}, i_visits}

            distance == 2.0 ->
              # vertical space between, increment ty only
              {{hx, new_hy}, {tx, ty+1}, MapSet.put(i_visits, {tx, ty+1})}

            distance > 2.0 and tx < hx ->
              # tail is down and left of Head. move tx+1, ty+1
              {{hx, new_hy}, {tx+1, ty+1}, MapSet.put(i_visits, {tx+1, ty+1})}

            distance > 2.0 and tx > hx ->
              # tail is down and right of Head. move tx-1, ty+1
              {{hx, new_hy}, {tx-1, ty+1}, MapSet.put(i_visits, {tx-1, ty+1})}
          end
        else
          {i_positions, MapSet.put(i_visits, }
        end
      end)
    end)
  end

  defp do_move({:down, amount}, acc) do
    # decrement hy
    Enum.reduce(1..amount, acc, fn _i, {{hx, hy}, {tx, ty}, visits} ->
      new_hy = hy - 1
      distance = euc_distance({hx, new_hy}, {tx, ty})

      cond do
        distance < 2.0  ->
          # kitty corner, tail does not need to move
          {{hx, new_hy}, {tx, ty}, visits}

        distance == 2.0 ->
          # vertical space between, decrement ty only
          {{hx, new_hy}, {tx, ty-1}, MapSet.put(visits, {tx, ty-1})}

        distance > 2.0 and tx < hx ->
          # tail is above and left of Head. move tx+1, ty-1
          {{hx, new_hy}, {tx+1, ty-1}, MapSet.put(visits, {tx+1, ty-1})}

        distance > 2.0 and tx > hx ->
          # tail is above and right of Head. move tx-1, ty-1
          {{hx, new_hy}, {tx-1, ty-1}, MapSet.put(visits, {tx-1, ty-1})}
      end
    end)
  end

  defp do_move({:left, amount}, acc) do
    # decrement hx
    Enum.reduce(1..amount, acc, fn _i, {{hx, hy}, {tx, ty}, visits} ->
      new_hx = hx - 1
      distance = euc_distance({new_hx, hy}, {tx, ty})

      cond do
        distance < 2.0  ->
          # kitty corner, tail does not need to move
          {{new_hx, hy}, {tx, ty}, visits}

        distance == 2.0 ->
          # horizontal space between, decrement tx only
          {{new_hx, hy}, {tx-1, ty}, MapSet.put(visits, {tx-1, ty})}

        distance > 2.0 and ty < hy ->
          # tail is below and right of Head. move tx-1, ty+1
          {{new_hx, hy}, {tx-1, ty+1}, MapSet.put(visits, {tx-1, ty+1})}

        distance > 2.0 and ty > hy ->
          # tail is above and right of Head. move tx-1, ty-1
          {{new_hx, hy}, {tx-1, ty-1}, MapSet.put(visits, {tx-1, ty-1})}
      end
    end)
  end

  defp do_move({:right, amount}, acc) do
    # increment hx
    Enum.reduce(1..amount, acc, fn _i, {{hx, hy}, {tx, ty}, visits} ->
      new_hx = hx + 1
      distance = euc_distance({new_hx, hy}, {tx, ty})

      cond do
        distance < 2.0  ->
          # kitty corner, tail does not need to move
          {{new_hx, hy}, {tx, ty}, visits}

        distance == 2.0 ->
          # horizontal space between, increment tx only
          {{new_hx, hy}, {tx+1, ty}, MapSet.put(visits, {tx+1, ty})}

        distance > 2.0 and ty < hy ->
          # tail is below and left of Head. move tx+1, ty+1
          {{new_hx, hy}, {tx+1, ty+1}, MapSet.put(visits, {tx+1, ty+1})}

        distance > 2.0 and ty > hy ->
          # tail is above and left of Head. move tx+1, ty-1
          {{new_hx, hy}, {tx+1, ty-1}, MapSet.put(visits, {tx+1, ty-1})}
      end
    end)
  end

  defp count_visted_spaces({_, _, visits}) do
    visits
    |> MapSet.size()
    |> IO.inspect(label: "number of spots tail has visited")
  end

  defp parse_move(<<dir::binary-size(1), " ">> <> dist) do
    to_dir(dir, String.to_integer(dist))
  end

  defp to_dir("R", dist), do: {:right, dist}
  defp to_dir("U", dist), do: {:up, dist}
  defp to_dir("L", dist), do: {:left, dist}
  defp to_dir("D", dist), do: {:down, dist}

  def euc_distance({hx, hy} = _head, {tx, ty} = _tail) do
    :math.sqrt(:math.pow(ty-hy, 2) + :math.pow(tx-hx, 2))
  end
end

Day9RopeBridgePt2.run("input.test")
