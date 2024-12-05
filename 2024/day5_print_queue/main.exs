defmodule Day5 do
  @moduledoc """
  Day 5: Printe queue
  """

  @init_map %{before: MapSet.new(), after: MapSet.new()}

  def part1(rules, updates) do
    IO.inspect(updates, label: "updates")

    ruleset = 
      Enum.reduce(rules, %{}, fn {l, r}, acc ->
        # Map.update/4 doesn't run the update function when it doesn't find the
        # key. So i have to initialize it to ensure i don't miss an entry. blah
        acc_init = 
          case {Map.get(acc, l), Map.get(acc, r)} do
            {nil, nil} -> Map.merge(acc, %{l => @init_map, r => @init_map})
            {_l_prev, nil} -> Map.put(acc, r, @init_map)
            {nil, _r_prev} -> Map.put(acc, l, @init_map)
            {_l_prev, _r_prev} -> acc
          end

        acc_init
        |> Map.update!(l, fn %{before: bf} = places ->
          %{places | before: MapSet.put(bf, r)}
        end)
        |> Map.update!(r, fn %{after: aft} = places ->
          %{places | after: MapSet.put(aft, l)}
        end)
      end)
      |> IO.inspect(label: "ruleset")

    Enum.filter(updates, &validate_update(&1, ruleset))
    |> IO.inspect(label: "after update")
    |> Enum.reduce(0, &middle_of_update/2)
    |> IO.inspect(label: "part1 answer")
  end

  defp validate_update(updates, ruleset) do
    updates
    |> Enum.with_index()
    |> Enum.all?(fn {update, idx} ->
      # IO.inspect(update, label: "UPDATE")
      updates_l = Enum.slice(updates, 0, idx) |> MapSet.new()
      updates_r = Enum.slice(updates, idx+1, length(updates)) |> MapSet.new()
      # IO.inspect(updates_l, label: "updates_l")
      # IO.inspect(updates_r, label: "updates_r")

      %{before: before, after: aft} = rules = Map.get(ruleset, update)
      # IO.inspect(before, label: "before")
      # IO.inspect(aft, label: "aft")
      empty = MapSet.new()

      case {MapSet.difference(updates_l, aft), MapSet.difference(updates_r, before)} do
        {^empty, ^empty} ->
          true

        res ->
          IO.inspect(res, label: "res false case")
          false
      end
    end)
  end

  defp middle_of_update(update, acc) do
    # IO.inspect(update, label: "update")
    acc + Enum.at(update, div(length(update)-1,2))
  end



  def part2(_rules, _updates) do
  end
end

file = "input"
[rules, updates] = 
  File.read!(file)
  |> String.split("\n\n", trim: true, parts: 2)

rules = 
  rules
  |> String.split("\n", trim: true)
  |> Enum.map(fn rule -> 
    [l, r] = String.split(rule, "|", parts: 2)

    {String.to_integer(l), String.to_integer(r)}
  end)
  # |> IO.inspect(label: "rules")

updates = 
  updates
  |> String.split("\n", trim: true)
  |> Enum.map(fn update -> 
    String.split(update, ",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end)
  # |> IO.inspect(label: "updates")

Day5.part1(rules, updates)
Day5.part2(rules, updates)


# 47 | 53 13 61 29
# 97 | 13 61 47 29 53 75
# 75 | 29 53 47 61 13
# 61 | 13 53 29
# 29 | 13
# 53 | 29 13
