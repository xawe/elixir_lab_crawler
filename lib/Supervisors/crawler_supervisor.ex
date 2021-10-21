defmodule Supervisors.CrawlerSupervisor do
  use GenServer

  def start_link(state \\[]) do
    GenServer.start_link(__MODULE__, [])

    children = [
      #Supervisor.child_spec({Caller, [[], Caller01]}, id: :Caller01)
      {DynamicSupervisor, strategy: :one_for_one, name: DynamicCaller, id: C00}
    ]
    Supervisor.start_link(children, name: :CrawlerSupervisor, strategy: :one_for_one)
  end


  def init(init_arg) do
  {:ok, init_arg}
  end


  def f0() do
    {r, id} = DynamicSupervisor.start_child(DynamicCaller, Caller)
    result = GenServer.cast(id, {:test, 10})
    IO.inspect(result)
  end

  def f1() do
    {_r, id} = DynamicSupervisor.start_child(DynamicCaller, Caller)
    IO.inspect(id)
    result = GenServer.call(id, :queue)
    IO.inspect(result)
  end

  def f3() do
    {_r, id} = DynamicSupervisor.start_child(DynamicCaller, Caller)
    IO.inspect(id)
    result = GenServer.call(id, {:get_data, "url Teste"})
    Process.exit(id, :done)
    IO.inspect(result)
  end


end
