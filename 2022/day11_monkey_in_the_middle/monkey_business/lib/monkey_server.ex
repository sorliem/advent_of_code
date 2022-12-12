defmodule MonkeyServer do
  @moduledoc """
  """

  def start_link(monkey) do
    id = monkey.id
    name = Module.concat(__MODULE__, :"Id#{id}")

    GenServer.start_link(__MODULE__, monkey, name: name)
  end

  def init(monkey) do
    {:ok, monkey}
  end

  def child_spec(monkey: monkey) do
    id = monkey.id
    new_id = Module.concat(__MODULE__, :"Id#{id}")

    %{
      id: new_id,
      start: {__MODULE__, :start_link, [monkey]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
