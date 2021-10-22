defmodule Caller do
  use GenServer

  @store  ResultStore

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state) do
    #DynamicSupervisor.start_link(__MODULE__, state)
    GenServer.start_link(__MODULE__, state)
  end

  def init(init_args) do
    #DynamicSupervisor.init(strategy: :one_for_one)
    {:ok, init_args}
  end

  def handle_cast({:process, url}, _state) do
    {_, result_data} = HTTPoison.get(url)
    recipe = %{
        name: get_smoothie_name(result_data.body),
        ingredients: get_smoothie_ingredients(result_data.body),
        directions: get_smoothie_directions(result_data.body)
    }
    @store.add(recipe)
    GenServer.cast(self(), {:terminate})
    {:noreply, :ok}
  end

  def handle_cast({:terminate}, _) do
    :timer.sleep(10000)
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


  def get_smoothie_name(body) do
    body
    |> Floki.parse_document!()
    |> Floki.find("h1.headline")
    |> Floki.text()
  end

  def get_smoothie_ingredients(body) do
    body
    |> Floki.parse_document!()
    |> Floki.find("label.checkbox-list")
    |> Floki.text(sep: "+")
    |> String.split("+")
  end

  def get_smoothie_directions(body) do
    body
    |> Floki.parse_document!()
    |> Floki.find("div.paragraph")
    |> Floki.text(sep: "=>")
    |> String.split("=>")
  end

end
