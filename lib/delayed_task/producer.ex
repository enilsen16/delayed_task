defmodule DelayedTask.Producer do
  use Experimental.GenStage

  def start_link do
    Experimental.GenStage.start_link(__MODULE__, 0, name: __MODULE__)
  end

  # Callbacks

  def init(counter) do
    {:producer, counter, dispatcher: Experimental.GenStage.BroadcastDispatcher}
  end

  def handle_demand(demand, state) do
    events = Enum.to_list(state..state+demand-1)
    {:noreply, events, state+demand}
  end
end
