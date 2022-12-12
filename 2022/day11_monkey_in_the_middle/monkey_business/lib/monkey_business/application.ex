defmodule MonkeyBusiness.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    monkey_children = build_children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MonkeyBusiness.Supervisor]
    Supervisor.start_link(monkey_children, opts)
  end

  defp build_children() do
    :monkey_business
    |> :code.priv_dir()
    |> Path.join("input.test")
    |> MonkeyBusiness.build_monkeys()
    |> Enum.map(fn monkey ->
      args = [monkey: monkey]
      {MonkeyServer, args}
    end)
  end
end
