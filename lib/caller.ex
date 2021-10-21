defmodule Caller do
  use GenServer

  @store  ResultStore

  def start_link(state) do
    DynamicSupervisor.start_link(__MODULE__, state)
  end

  def init(_init_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def handle_cast({:process, url}) do
    GenServer.cast(:process, url)
  end



  def process(url) do
    {_, pid} = DynamicSupervisor.start_child(DynamicCaller, Simple)
    {_, body} = url
    |> HTTPoison.get(url)
    #|> Enum.map(fn {_, result} -> result.body end)

    r = %{
        name: get_smoothie_name(body),
        ingredients: get_smoothie_ingredients(body),
        directions: get_smoothie_directions(body)
    }
    @store.add({pid, r})
    #Process.exit(pid, :done)
  end

  def get_data_from_url(url) do
    url
    |> Enum.map(fn url -> HTTPoison.get(url) end)
    |> Enum.map(fn {_, result} -> result.body end)
  end


  def get_smoothie_name(body) do
    body
    |> Floki.parse_document!()
    #|> Floki.find("div#main-header")
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
