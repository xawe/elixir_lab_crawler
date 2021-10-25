defmodule Caller2 do
  use GenServer

  @store ResultStore

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state) do
    # DynamicSupervisor.start_link(__MODULE__, state)
    GenServer.start_link(__MODULE__, state)
  end

  def init(init_args) do
    # DynamicSupervisor.init(strategy: :one_for_one)
    {:ok, init_args, 60_000}
  end

  def handle_cast({:process, url}, _state) do
    HTTPoison.get(url)
    |> build_recipe()
  end

  def handle_cast({:terminate}, _) do
    :timer.sleep(15_000)
    Process.exit(self(), :normal)
  end

  def process(url, max_process) do
    process_list = warmup_process(max_process)
    spawn_process(url, process_list, [])
    {:ok, :done}
  end

  @spec spawn_process(nonempty_maybe_improper_list, any, maybe_improper_list) :: no_return
  def spawn_process([h_url | t_url] =urls, process_list, remaining_process_list) do
    {pid, tail_process} = pick_process(process_list, remaining_process_list)
    GenServer.cast(pid, {:process, h_url})
    spawn_process(t_url, process_list, tail_process)
  end

  def spawn_process(_ , _, _) do
    IO.puts("Processos criados com sucesso")
    {:ok, :done}
  end

  def spawn_process([h_url | []] = urls , _, _) do
    IO.puts("Processos criados com sucesso")
    {:ok, :done}
  end

  @doc """
  Inicia uma quantidade pre determinada de processos para tratar as requisições de urls
  """
  def warmup_process(max_process) do
    Enum.map(1..max_process, fn _ -> DynamicSupervisor.start_child(DynamicCaller, Caller2) end)
    |> Enum.map(fn {_, p} -> p end)
  end

  def pick_process(_process_list, [h | t]) do
    {h, t}
  end

  def pick_process(process_list, []) do
   [h | t ] = process_list
   {h, t}
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
