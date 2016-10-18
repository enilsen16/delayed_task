defmodule DelayedTask.Consumer do
  use Experimental.GenStage

  def start_link() do
    Experimental.GenStage.start_link(__MODULE__, :state)
  end

  # Callbacks

  def init(state) do
    {:consumer, state, subscribe_to: [DelayedTask.Producer]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      %{id: id, payload: payload} = event
      {module, function, args} = :erlang.binary_to_term(payload)
      task = start_task(module, function, args)

      task
      |> Task.yield(1000)
      |> yield_to_status(task)
      |> update(id)
    end
    {:noreply, [], state}
  end

  defp start_task(mod, func, args) do
    Task.Supervisor.async_nolink(DelayedTask.TaskSupervisor, mod  , func, args)
  end

  defp yield_to_status({:ok, _}, _) do
    "success"
  end
  defp yield_to_status({:exit, _}, _) do
    "error"
  end
  defp yield_to_status(nil, task) do
    Task.shutdown(task)
    "timeout"
  end

  defp update(status, id) do
    DelayedTask.Task.update_status(id, status)
  end
end
