defmodule DelayedTask.Producer do
  use Experimental.GenStage

  import Ecto.Query
  import DelayedTask.Repo

  def start_link do
    Experimental.GenStage.start_link(__MODULE__, 0, name: __MODULE__)
  end

  # Callbacks

  def init(counter) do
    {:producer, counter}
  end

  def handle_demand(demand, state) when demand > 0 do
    limit = demand + state
    {:ok, {count, events}} = take(limit)
    {:noreply, events, limit - count}
  end

  def handle_info(:yo_you_have_data, state) do
    {:ok, {count, events}} = take(state)
    {:noreply, events, state - count}
  end

  defp take(limit) do
    DelayedTask.Repo.transaction fn ->
      ids = DelayedTask.Repo.all waiting(limit)
      {count, events} = DelayedTask.Repo.update_all by_ids(ids),
                                        [set: [status: "running"]],
                                        [returning: [:id, :payload]]
      {count, events}
    end
  end

  defp by_ids(ids) do
    from t in "tasks", where: t.id in ^ids
  end

  defp waiting(limit) do
    from t in "tasks",
      where: t.status == "waiting",
      limit: ^limit,
      select: t.id,
      lock: "FOR UPDATE SKIP LOCKED"
  end
end
