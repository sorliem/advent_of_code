defmodule MonkeyServer do
  @moduledoc """
  """

  alias MonkeyBusiness.Monkey

  def start_link(monkey) do
    id = monkey.id
    name = Module.concat(__MODULE__, :"Id#{id}")

    GenServer.start_link(__MODULE__, monkey, name: name)
  end

  def init(monkey) do
    {:ok, monkey}
  end

  def handle_call(:get_stats, _from, monkey) do
    list = :queue.to_list(monkey.items)

    {:reply, {list, monkey.inspect_count}, monkey}
  end

  def handle_info({:do_turn, from_pid, ref}, monkey) do
    # for each item in queue, do operation, test, and send to monkey
    q_len = :queue.len(monkey.items)

    {_queue, new_inspect_count} =
      Enum.reduce(0..q_len-1, {monkey.items, monkey.inspect_count}, fn _, {monkey_queue, inspect_count} ->
        case :queue.out(monkey_queue) do
          {{:value, item}, rem_queue} ->
            new_val = monkey.operation_fn.(item)
            val_after_worry = Integer.floor_div(new_val, 3)

            {to_pid, to_monkey_id} =
              if monkey.test_fn.(val_after_worry) do
                {monkey_id_to_pid(monkey.test_true_id), monkey.test_true_id}
              else
                {monkey_id_to_pid(monkey.test_false_id), monkey.test_false_id}
              end

            ref = make_ref()
            # IO.puts("monkey #{monkey.id} throwing #{val_after_worry} to monkey #{to_monkey_id}")
            # IO.puts("monkey #{monkey.id} sending #{val_after_worry} to monkey #{inspect to_pid}")

            send(to_pid, {:store_item, val_after_worry, self(), ref})

            receive do
              {:stored, ^ref} -> :ok
            end

            {rem_queue, inspect_count + 1}

          {:empty, rem_queue} ->
            # queue is empty
            {rem_queue, inspect_count}
        end
      end)

    send(from_pid, {:turn_done, ref})

    {:noreply, %Monkey{monkey | items: :queue.new(), inspect_count: new_inspect_count}}
  end

  def handle_info({:store_item, item, from_pid, ref}, monkey) do
    new_items = :queue.in(item, monkey.items)

    send(from_pid, {:stored, ref})

    {:noreply, %Monkey{monkey | items: new_items}}
  end

  defp monkey_id_to_pid(id) do
    module = Module.concat(__MODULE__, :"Id#{id}")

    Process.whereis(module)
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
