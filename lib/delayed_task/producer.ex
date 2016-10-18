defmodule DelayedTask.Producer do
  use Experimental.GenStage

  @name __MODULE__

  def start_link do
    Experimental.GenStage.start_link(__MODULE__, 0, name: @name)
  end

  def enqueue(module, function, args) do
    DelayedTask.Task.enqueue("waiting", :erlang.term_to_binary({module, function, args}))
    Process.send(@name, :enqueued, [])
    :ok
  end

  # Callbacks

  def init(counter) do
    {:producer, counter}
  end

  def handle_cast(:enqueued, state) do
    serve_jobs(state)
  end

  def handle_demand(demand, state) do
    serve_jobs(demand + state)
  end

  def handle_info(:yo_you_have_data, state) do
    {count, events} = DelayedTask.Task.take(state)
    {:noreply, events, state - count}
  end

  defp serve_jobs(0) do
    {:noreply, [], 0}
  end

  defp serve_jobs(limit) when limit > 0 do
    {count, events} = DelayedTask.Task.take(limit)
    Process.send_after(@name, :enqueued, 60_000)
    {:noreply, events, limit - count}
  end
end
