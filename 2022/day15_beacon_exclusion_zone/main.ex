defmodule Day15BeaconExclusionZone do
  @moduledoc """
  """

  @table :blackout_coords

  # DOES NOT WORK ON INPUT. DIAMONDS WAY TOO BIG DOES NOT FINISH, WOULD PROBABLY take
  # years to run. Don't know of a more memory efficient method atm.
  def run(file) do
    :ets.new(@table, [:named_table, :set, :public])
    :observer.start()

    file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Stream.flat_map(&parse/1)
    |> Task.async_stream(&find_coverage/1, timeout: :infinity)
    |> Enum.to_list()

    IO.puts "done calculating blackout spaces"

    :ets.tab2list(@table)
    # |> List.flatten()
    # |> Enum.uniq()
    |> Enum.count(fn
      {_x, 2000000} ->
        # IO.inspect(coord, label: "coord on y=10")
        # IO.inspect(coord, label: "coord on y=2000000")
        true

      _ -> false
    end)
    |> IO.inspect(label: "row 2000000 num of spaces that cannot contain beacon")
  end

  defp find_coverage([{_sx, _sy}=sensor, {_bx, _by}=beacon]) do
    radius = taxi_distance(sensor, beacon)
    IO.inspect(radius, label: "radius at sensor #{inspect sensor}")

    spaces_around(sensor, radius)
  end

  def spaces_around({sx, sy}=center, radius) do
    x_rng = Range.new(sx-radius, sx+radius)
    |> IO.inspect(label: "x_rng")
    y_rng = Range.new(sy-radius, sy+radius)
    |> IO.inspect(label: "y_rng")
    x_len = (sx+radius) - (sx-radius)

    if Range.disjoint?(y_rng, 2_000_000..2_000_000) do
      # skip diamonds that don't intersect y=2mil
      IO.inspect(center, label: "y_rng=#{inspect y_rng}, skipping center")
    else
      Enum.each(x_rng, fn x ->
        # 23 * 70=1610, a multiple of 23.
        # hacky progress tracker
        if rem(x, 1610) == 0 do
          IO.puts("#{(x-(sx-radius)) / x_len}% the way through x_rng for center #{inspect center}")
        end

        Enum.each(y_rng, fn
          2_000_000=y ->
            # only calculate for y=2million
            if taxi_distance(center, {x,y}) <= radius do
              :ets.insert(@table, {x,y})
            end

          _ ->
            :ok
        end)
      end)
    end
  end

  def taxi_distance({sx, sy}, {bx, by}) do
    abs(by - sy) + abs(bx - sx)
  end

  # EXAMPLE: Sensor at x=2, y=18: closest beacon is at x=-2, y=15
  defp parse(line) do
    regex = ~r/^Sensor at x=(?<sx>[-\d]+), y=(?<sy>[-\d]+): closest beacon is at x=(?<bx>[-\d]+), y=(?<by>[-\d]+)/
    cap = Regex.named_captures(regex, line)

    [[
      {String.to_integer(cap["sx"]), String.to_integer(cap["sy"])},
      {String.to_integer(cap["bx"]), String.to_integer(cap["by"])}
    ]]
  end
end

Day15BeaconExclusionZone.run("input")
