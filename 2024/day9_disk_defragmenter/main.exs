defmodule Day9 do
  @moduledoc """
  Day9: Disk Defragmenter
  """

  def part1(diskmap) do
    {expanded_diskmap, _, _} =
      diskmap
      |> Enum.reduce({[], :file, 0}, fn
        file_num, {acc, :file, idx} ->
          things = for _ <- 0..file_num-1, do: idx
          {[things | acc], :free_space, idx + 1}

        0, {acc, :free_space,  idx} ->
          {acc, :file, idx}

        sp_num, {acc, :free_space,  idx} ->
          things = for _ <- 0..sp_num-1, do: "."
         
          {[things | acc], :file, idx}
      end)

    expanded_diskmap =
      expanded_diskmap
      |> Enum.reverse()
      |> List.flatten()

    # expanded_diskmap
    # |> IO.inspect(label: "expanded_diskmap")

    compact_disk(expanded_diskmap)
    |> do_checksum()
    |> IO.inspect(label: "part1 answer")
  end

  def compact_disk(diskmap) do
    num_nums = count_nums(diskmap)
    {res, _} =
    Enum.reduce(diskmap, {[], Enum.reverse(diskmap)}, fn 
        ".", {acc, rev_disk} -> 
          {end_num, rem_disk} = find_end_num(rev_disk)
          {[end_num | acc], rem_disk}

        int, {acc, rev_disk} -> 
          {[int | acc], rev_disk}
    end)

    Enum.reverse(res)
    |> Enum.slice(0, num_nums)
  end

  def do_checksum(compact_disk) do
    compact_disk
    |> Enum.with_index()
    |> Enum.reduce(0, fn {file_id, idx}, acc ->
      acc + (file_id * idx)
    end)
  end

  def find_end_num([i | rest]) when is_integer(i), do: {i, rest}
  def find_end_num(["." | rest]), do: find_end_num(rest)

  def count_nums(diskmap) do
    Enum.reduce(diskmap, 0, fn 
     ".", acc -> acc
     _int, acc -> acc + 1
    end)
  end
end

file = "input"

diskmap = 
  File.read!(file)
  |> String.trim()
  |> then(fn str ->
    String.split(str,"", trim: true)
    |> Enum.map(&String.to_integer/1)
  end)
  # |> IO.inspect(label: "diskmap")



Day9.part1(diskmap)
# Day8.part2(coords)
  
