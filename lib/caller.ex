defmodule Caller do
  use GenServer

  def start_link(state) do
    DynamicSupervisor.start_link(__MODULE__, state)
  end

  def init(_init_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec handle_call(:t1, any, []) :: {:reply, <<_::88>>}
  def handle_call(:t1, _from, _state) do
    {:reply, "Hello teste", [:ok]}
  end

  def handle_call(:queue, _from, _state) do

    {:reply, "jhg", :ok}
  end

  def handle_cast({:test, value}) do

    data = 1..10_000_000
    |> Enum.sort()
    |> Enum.each(fn x -> x * 2 end)
    d2 = data
    IO.inspect(d2)
    exit(self)
    {:noreply, value}
  end

  def t1(value) do
    GenServer.call(__MODULE__, :t1)
  end

  def queue, do: GenServer.call(__MODULE__, :queue)

  def test, do: GenServer.cast(__MODULE__, :test)

  def get_data_from_url(url) do
    url
    |> Enum.map(fn url -> HTTPoison.get(url) end)
    |> Enum.map(fn {_, result} -> result.body end)
  end


  def hello() do
    :world
  end
end
