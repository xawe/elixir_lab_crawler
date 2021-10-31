defmodule Mediator do
  @moduledoc """
  API resonsável por prover aos modulos WEB as funções necessárias para iniciar o processamento via Processos OTP.

  Atualmente, há duas implementações

  - 1) Um processo é criado para cada URL recebida

  - 2) Um pool de processos é criado com base na quantidade recebida, e então a distribuição de mensagens é feita de forma cíclica

  """

  def process(url, url_fun) do
    {_, pid} = DynamicSupervisor.start_child(DynamicCaller, ProcessServer)
    GenServer.cast(pid, {:process, url, url_fun})
  end

  def process(url, max_process, url_fun) do
    process_list = warmup_process(max_process)
    spawn_process(url, process_list, [], url_fun)
    {:ok, :done}
  end

  def spawn_process([h_url | t_url], process_list, remaining_process_list, url_fun) do
    {pid, tail_process} = pick_process(process_list, remaining_process_list)
    GenServer.cast(pid, {:process, h_url, url_fun})
    spawn_process(t_url, process_list, tail_process, url_fun)
  end

  def spawn_process(_, _, _, _) do
    IO.puts("Processos criados com sucesso")
    {:ok, :done}
  end

  @doc """
  Inicia uma quantidade pre determinada de processos para tratar as requisições de urls
  """
  def warmup_process(max_process) do
    Enum.map(1..max_process, fn _ ->
      DynamicSupervisor.start_child(DynamicCaller, ProcessServer)
    end)
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
    [h | t] = process_list
    {h, t}
  end
end
