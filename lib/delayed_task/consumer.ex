defmodule DelayedTask.Consumer do
  use Experimental.GenStage

  def start_link do
    Experimental.GenStage.start_link(__MODULE__, :whatever)
  end

  # Callbacks

  def init(state) do
    {:consumer, state, subscribe_to: [{DelayedTask.Producer, min_demand: 50, max_demand: 100}]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      %{id: id, payload: payload} = event
      {module, function, args} = :erlang.binary_to_term(payload)
      Kernel.apply(module, function, args)
    end
    {:noreply, [], state}
  end
end
