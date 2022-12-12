defmodule MonkeyBusiness.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    monkey_children = build_children()

    children =
      monkey_children ++ [
        {Task, &start_game/0}
      ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MonkeyBusiness.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp start_game() do
    MonkeyBusiness.play_game()
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
