defmodule ProcessServer do
  use GenServer

  @doc """
  GenServer responsável por tratar
  """

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(init_args) do
    {:ok, init_args, get_prop(:cfg, :timeout)}
  end

  def handle_cast({:process, url}, _state) do
    HTTPoison.get(url)
    |> Web.AllRecipes.build_recipe()
  end

  def handle_cast({:terminate}, _) do
    :timer.sleep(get_prop(:cfg, :kill_process))
    Process.exit(self(), :normal)
  end



  defp get_prop(key, prop_name) do
    Application.fetch_env!(key, prop_name)
  end
end
