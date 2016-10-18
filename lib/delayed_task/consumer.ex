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
      IO.inspect {self(), event}
    end
    {:noreply, [], state}
  end
end
