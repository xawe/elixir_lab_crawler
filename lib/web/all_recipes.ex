defmodule Web.AllRecipes do
  @moduledoc """
    Expões funções responsáveis por consultar e tratar as informações obtidades no site AllRecipes.com

    A implementação original é de autoria de Julien Corb e pode ser obtida de forma completa no post https://medium.com/@Jules_Corb/web-scraping-with-elixir-using-httpoison-and-floki-26ebaa03b076

    Algumas alterações foram feitas para possibilitar a chamada via processos e corrigir erros causados por alterações no front ent, já que o post original é de 2019

  """

  @store ResultStore

  @url_call_function &Web.AllRecipes.build_recipe/1

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

  def get_smoothies_recipe(pool_count, fun) do
    {status, urls} = read_main_url()
    fun.(urls, pool_count, @url_call_function)
    {:created, status}
  end

  def get_smoothies_recipe(fun) do
    {status, urls} = read_main_url()
    Enum.each(urls, fn url -> fun.(url, @url_call_function) end)
    {:created, status}
  end

  def get_data_from_url(url) do
    url
    |> Enum.map(fn url -> HTTPoison.get(url) end)
    |> Enum.map(fn {_, result} -> result.body end)
  end

  @spec build_recipe({any, any}) :: {:noreply, :error | :ok}
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
