defmodule Caller2 do
  use GenServer

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
    |> WebShredder.AllRecipes.build_recipe()
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
  def spawn_process([h_url | t_url] = urls, process_list, remaining_process_list) do
    {pid, tail_process} = pick_process(process_list, remaining_process_list)
    GenServer.cast(pid, {:process, h_url})
    spawn_process(t_url, process_list, tail_process)
  end

  def spawn_process(_ , _, _) do
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

  @doc """
  Obtem um processo da lista de processos, fazendo uma rotação entre os processos disponíveis

  ## Parameters
    - _process_list : recebe a lista completa de processos criados para o job

    - [h | t] a lista contendo o Head(processo atual) e Tail(processos restantes da rotação)
  """
  def pick_process(_process_list, [h | t]) do
    {h, t}
  end

  def pick_process(process_list, []) do
   [h | t ] = process_list
   {h, t}
  end



end
