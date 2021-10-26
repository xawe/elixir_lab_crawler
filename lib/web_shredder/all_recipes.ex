defmodule WebShredder.AllRecipes do

  @store ResultStore

  def read_main_url() do
    case HTTPoison.get(
           "https://www.allrecipes.com/recipes/138/drinks/smoothies/?internalSource=hubcard&referringContentType=Search&clickId=cardslot%201"
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        urls =
          body
          |> Floki.parse_document!()
          |> Floki.find("a.card__titleLink")
          |> Floki.attribute("href")

        {:ok, urls}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  def get_smoothies_recipe(max_process, fun) do
    {status, urls} = read_main_url()
    fun.(urls, max_process)
    #Caller2.process(urls, max_process)
    {:created, status}
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
