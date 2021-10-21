defmodule Simple do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
    #DynamicSupervisor.start_link(__MODULE__, state)
  end

  def init(args) do
    {:ok, args}
    #DynamicSupervisor.init(strategy: :one_for_one)
  end


  def handle_call(:c, from, _state) do
    {:reply, "Hello", from}
  end

  def handle_call({:d, value}, from, _state) do
    {:reply, value, from}
  end

  def handle_cast({:e, value}, _state \\[]) do
    {:noreply, "#{value} >> OK"}
  end

  def c(value) do
    GenServer.call(__MODULE__, {:c, value})
  end

  def d(value) do
    GenServer.call(__MODULE__, {:d, value})
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

  def one(value) do
    {_r, id} = DynamicSupervisor.start_child(DynamicCaller, Simple)
    IO.inspect(value)
    result = GenServer.call(id, {:c, value})
    IO.inspect("===== #{result}")
  end

  def two(value, at) do
    {_r, id} = DynamicSupervisor.start_child(DynamicCaller, Simple)
    IO.inspect(id)
    IO.inspect(Process.alive?(id))
    r = GenServer.call(id, {:d, value})
    Process.exit(id, :sucess)
    IO.inspect(Process.alive?(id))
    IO.inspect(at)
    r

  end

end
