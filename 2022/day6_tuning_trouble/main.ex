defmodule Day6TuningTrouble do
  @moduledoc """
  """

  def run(file) do
    lines =
      file
      |> File.read!()
      |> String.split("\n", trim: true)

    Enum.each(lines, &pt1_find_start_of_packet/1)
    Enum.each(lines, &pt2_find_start_of_message/1)
  end

  defp pt1_find_start_of_packet(buffer) do
    len = String.length(buffer)

    Enum.reduce_while(0..len, nil, fn i, _acc ->
      quad = String.slice(buffer, i, 4)


      uniq_letters =
        quad
        |> String.codepoints()
        |> Enum.uniq()

        if length(uniq_letters) == 4 do
          IO.inspect({quad, i + 4}, label: "pt1. unique start-of-packet marker")
          {:halt, nil}
        else
          {:cont, nil}
        end
    end)
  end

  defp pt2_find_start_of_message(buffer) do
    len = String.length(buffer)

    Enum.reduce_while(0..len, nil, fn i, _acc ->
      slice = String.slice(buffer, 0 + i, 14)

      uniq_letters =
        slice
        |> String.codepoints()
        |> Enum.uniq()

        if length(uniq_letters) == 14 do
          IO.inspect({slice, i + 14}, label: "pt2. unique start-of-message marker")
          {:halt, nil}
        else
          {:cont, nil}
        end
    end)
  end
end

Day6TuningTrouble.run("input")
