defmodule MonkeyBusiness.Application do
  @moduledoc false

  use Application

  alias MonkeyBusiness.Monkey

  @impl true
  def start(_type, _args) do
    children = build_children() ++ [{Task, &MonkeyBusiness.play_game/0}]

    opts = [strategy: :one_for_one, name: MonkeyBusiness.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp build_children() do
    monkeys =
      :monkey_business
      |> :code.priv_dir()
      |> Path.join("input")
      |> MonkeyBusiness.build_monkeys()

    # multiply all divisors together to get a common n_mult that
    # each value can be modded by to keep integers "worry" managable.
    n_mult =
      Enum.reduce(monkeys, 1, fn monkey, acc ->
        monkey.div_n * acc
      end)

    IO.inspect(n_mult, label: "n_mult of all monkeys")

    monkeys
    |> Enum.map(fn monkey ->
      args = [monkey: %Monkey{monkey | common_mult_n: n_mult}]
      {MonkeyServer, args}
    end)
  end
end
