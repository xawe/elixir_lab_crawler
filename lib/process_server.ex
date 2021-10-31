defmodule ProcessServer do
  use GenServer

  @moduledoc """
  Módulo responsável levantar os processos de execução de url, e prover as funções necessárias para o funcionamento do GenServer
  """

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(init_args) do
    {:ok, init_args, get_prop(:cfg, :timeout)}
  end

  def handle_cast({:process, url, url_fun}, _state) do
    HTTPoison.get(url)
    |> url_fun.()

    # |> Web.AllRecipes.build_recipe()
  end

  def handle_cast({:terminate}, _) do
    :timer.sleep(get_prop(:cfg, :kill_process))
    Process.exit(self(), :normal)
  end

  defp get_prop(key, prop_name) do
    Application.fetch_env!(key, prop_name)
  end
end
