defmodule MonkeyBusiness.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = build_children() ++ [{Task, &MonkeyBusiness.play_game/0}]

    opts = [strategy: :one_for_one, name: MonkeyBusiness.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp build_children() do
    :monkey_business
    |> :code.priv_dir()
    |> Path.join("input")
    |> MonkeyBusiness.build_monkeys()
    |> Enum.map(fn monkey ->
      args = [monkey: monkey]
      {MonkeyServer, args}
    end)
  end
end
