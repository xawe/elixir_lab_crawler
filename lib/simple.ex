defmodule Simple do
  use GenServer

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
    #DynamicSupervisor.start_link(__MODULE__, state)
  end

  def init(args) do
    {:ok, args}
    #DynamicSupervisor.init(strategy: :one_for_one)
  end


  def handle_cast({:e, value}, _state \\[]) do
    {:noreply, "#{value} >> OK"}
  end


  def e(value, state \\ []) do
    IO.inspect("Starting")
    {_r, id} = DynamicSupervisor.start_child(DynamicCaller, Simple)
    IO.inspect(id)
    IO.inspect(Process.alive?(id))
    r = GenServer.cast(id, {:e, value})
    Process.exit(id, :sucess)
    IO.inspect(Process.alive?(id))
    IO.inspect(state)
    ResultStore.add(id)
    r
  end


end
