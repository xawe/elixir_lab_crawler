defmodule Caller33 do
  use GenServer

  @store ResultStore

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state) do
    # DynamicSupervisor.start_link(__MODULE__, state)
    GenServer.start_link(__MODULE__, state)
  end

  def init(init_args) do
    # DynamicSupervisor.init(strategy: :one_for_one)
    {:ok, init_args, 20_000}
  end

  def handle_cast({:process, url}, _state) do
    HTTPoison.get(url)
    |> build_recipe()
  end

  def handle_cast({:terminate}, _) do
    :timer.sleep(15_000)
    Process.exit(self(), :normal)
  end

  def process(url) do
    {_, pid} = DynamicSupervisor.start_child(DynamicCaller, Caller)
    GenServer.cast(pid, {:process, url})
  end

  def get_data_from_url(url) do
    url
    |> Enum.map(fn url -> HTTPoison.get(url) end)
    |> Enum.map(fn {_, result} -> result.body end)
  end

  def build_recipe({:ok, result_data}) do
    recipe = %{
      name: Smoothixir.get_smoothie_name(result_data.body),
      ingredients: Smoothixir.get_smoothie_ingredients(result_data.body),
      directions: Smoothixir.get_smoothie_directions(result_data.body)
    }

    @store.add(recipe)

    IO.puts("--------- || #{inspect(self())} OK || ----------")
    GenServer.cast(self(), {:terminate})
    {:noreply, :ok}
  end

  def build_recipe({_, _}) do
    IO.puts("--------- #{inspect(self())} NOT PROCESSED ----------")
    {:noreply, :error}
  end
end
