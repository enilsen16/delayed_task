defmodule DelayedTask.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: DelayedTask.Worker.start_link(arg1, arg2, arg3)
      # worker(DelayedTask.Worker, [arg1, arg2, arg3]),
      supervisor(DelayedTask.Repo, []),
      worker(DelayedTask.Producer, []),
      supervisor(Task.Supervisor, [[name: DelayedTask.TaskSupervisor]])
    ]

    consumers =
      for id <- 1..System.schedulers_online * 2 do
        worker(DelayedTask.Consumer, [], id: id)
      end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DelayedTask.Supervisor]
    Supervisor.start_link(children ++ consumers, opts)
  end

  def start_later(module, function, args) do
    payload = {module, function, args} |> :erlang.term_to_binary
    DelayedTask.Repo.insert_all "tasks", [
      %{status: "waiting", payload: payload}
    ]
    send DelayedTask.Producer, :yo_you_have_data
  end

  defdelegate enqueue(module, function, args), to: DelayedTask.Producer
end
