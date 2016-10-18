defmodule DelayedTask.Task do
  import Ecto.Query

  def update_status(id, status) do
    DelayedTask.Repo.update_all by_ids([id]), set: [status: status]
  end

  def enqueue(status, payload) do
    DelayedTask.Repo.insert_all "jobs", [
      %{status: status, payload: payload}
    ]
  end

  def take(limit) do
    {:ok, {count, events}} =
      DelayedTask.Repo.transaction fn ->
        ids = DelayedTask.Repo.all waiting(limit)
        DelayedTask.Repo.update_all by_ids(ids), [set: [status: "running"]], [returning: [:id, :payload]]
      end
    {count, events}
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
