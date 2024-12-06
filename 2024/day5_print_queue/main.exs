defmodule Day5 do
  @moduledoc """
  Day 5: Printe queue
  """


  def part1(ruleset, updates) do

    {valid, invalid} =
      Enum.reduce(updates, {[], []}, fn update, {valid, invalid}->
        if validate_update(update, ruleset) do
          {[update | valid], invalid}
        else
          {valid, [update | invalid]}
        end
      end)

    valid
    |> Enum.reduce(0, &middle_of_update/2)
    |> IO.inspect(label: "part1 answer")

    invalid
  end

  defp validate_update(updates, ruleset) do
    updates
    |> Enum.with_index()
    |> Enum.all?(fn {update, idx} ->
      updates_l = Enum.slice(updates, 0, idx) |> MapSet.new()
      updates_r = Enum.slice(updates, idx+1, length(updates)) |> MapSet.new()

      %{before: before, after: aft} = Map.get(ruleset, update)
      empty = MapSet.new()

      case {MapSet.difference(updates_l, aft), MapSet.difference(updates_r, before)} do
        {^empty, ^empty} ->
          true

        _dfif ->
          false
      end
    end)
  end

  defp middle_of_update(update, acc) do
    acc + Enum.at(update, div(length(update)-1,2))
  end

  def part2(ruleset, invalid_updates) do
    IO.inspect(invalid_updates, label: "invalid_updates")

    invalid_updates
    |> then(fn [update | _] -> [update] end)
    |> Enum.map(&fix_update(&1, ruleset))
    |> Enum.reduce(0, &middle_of_update/2)
    |> IO.inspect(label: "part2 answer NOT DONE!")
  end

  defp fix_update(update, ruleset) do
    Enum.reduce(update, [], fn 
      upd, [] -> [upd]

      upd, acc ->
        %{before: bf, after: af} = Map.get(ruleset, upd)
        pos = insert_pos(acc, upd, bf, af)
        acc
    end)
  end

  defp insert_pos(cur_update, upd, bf, af) do
    is_before? = MapSet.member?(bf, upd)
    is_after? = MapSet.member?(af, upd)
    IO.inspect(is_before?, label: "is_before?")
    IO.inspect(is_after?, label: "is_after?")

  end
end

file = "test_input"
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

init_map = %{before: MapSet.new(), after: MapSet.new()}

ruleset = 
  Enum.reduce(rules, %{}, fn {l, r}, acc ->
    # Map.update/4 doesn't run the update function when it doesn't find the
    # key. So i have to initialize it to ensure i don't miss an entry. blah
    acc_init = 
      case {Map.get(acc, l), Map.get(acc, r)} do
        {nil, nil} -> Map.merge(acc, %{l => init_map, r => init_map})
        {_l_prev, nil} -> Map.put(acc, r, init_map)
        {nil, _r_prev} -> Map.put(acc, l, init_map)
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

updates = 
  updates
  |> String.split("\n", trim: true)
  |> Enum.map(fn update -> 
    String.split(update, ",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end)

invalid_updates = Day5.part1(ruleset, updates)
Day5.part2(ruleset, invalid_updates)


# 47 | 53 13 61 29
# 97 | 13 61 47 29 53 75
# 75 | 29 53 47 61 13
# 61 | 13 53 29
# 29 | 13
# 53 | 29 13
