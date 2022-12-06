
IO.puts("part 1")

sorted_cal_counts =
  File.read!("input")
  |> String.trim()
  |> String.split("\n\n")
  |> Enum.map(fn str ->
      str
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()
  end)
  |> Enum.sort()

sorted_cal_counts
|> List.last()
|> IO.inspect(label: "max calories carried by an elf")

sorted_cal_counts
|> Enum.take(-3)
|> Enum.sum()
|> IO.inspect(label: "sum of top 3 calorie counts")
