defmodule Supervisors.CrawlerSupervisor do
  use GenServer

  def start_link(_state \\ []) do
    GenServer.start_link(__MODULE__, [])

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: DynamicCaller, id: C00}
    ]

    Supervisor.start_link(children, name: :CrawlerSupervisor, strategy: :one_for_one)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end
end
