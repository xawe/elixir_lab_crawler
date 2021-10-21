defmodule LabCrawler do
  @moduledoc """
  Documentation for `LabCrawler`.
  """




  def start() do
    :timer.tc(fn -> get_smoothies_recipe() end)

  end

  def get_smoothies_url() do
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

  def smoothies_html_body({_, urls}) do
    urls
    |> Enum.map(fn url -> HTTPoison.get(url) end)
    |> Enum.map(fn {_, result} -> result.body end)
  end

  @doc """
  Allow you to find the name of a smoothie within a page's html body.
  returns a String.
  ## Examples
      iex> Smoothixir.get_smoothie_name(body)
      "Mongolian Strawberry-Orange Juice Smoothie"
  """
  def get_smoothie_name(body) do
    body
    |> Floki.parse_document!()
    #|> Floki.find("div#main-header")
    |> Floki.find("h1.headline")
    |> Floki.text()
  end

  @doc """
  Allow you to find the ingredients of a smoothie within a page's html body.
  returns a List of strings.
  ## Examples
    iex> Smoothixir.get_smoothie_ingredients(body)
    ["1 cup chopped fresh strawberries", "1 cup orange juice", "10 cubes ice", "1 tablespoon sugar"]
  """
  def get_smoothie_ingredients(body) do
    body
    |> Floki.parse_document!()
    |> Floki.find("label.checkbox-list")
    #|> Floki.text()
    # |> Floki.attribute("label", "title")
    |> Floki.text(sep: "+")
    |> String.split("+")
  end


  def get_smoothie_directions(body) do
    # |> Floki.parse_document!()
    # |> Floki.find("label.checkbox-list")
    body
    |> Floki.parse_document!()
    |> Floki.find("div.paragraph")

    #|> Floki.find("span.recipe-directions__list--item")
    |> Floki.text(sep: "=>")
    |> String.split("=>")


  end

  def get_smoothies_html_body({_, urls}) do
    urls
    |> Enum.map(fn url -> HTTPoison.get(url) end)
    |> Enum.map(fn {_, result} -> result.body end)
  end

  def get_smoothies_recipe() do
    smoothies =
      get_smoothies_url()
      |> get_smoothies_html_body()
      |> Enum.map(fn body ->
        %{
          name: get_smoothie_name(body),
          ingredients: get_smoothie_ingredients(body),
          directions: get_smoothie_directions(body)
        }
      end)

    {:ok, smoothies}
  end

  @doc """
  Simple function that displays smoothies in a nice way in the console.
  ## Examples
    iex> Smoothixir.get_smoothies_recipe() |> Smoothixir.display_smoothies()
    Triple Threat Fruit Smoothie
    1 kiwi, sliced1 banana, peeled and chopped1/2 cup blueberries1 cup strawberries1 cup ice cubes1/2 cup orange juice1 (8 ounce) container peach yogurt
    In a blender, blend the kiwi, banana, blueberries, strawberries, ice, orange juice, and yogurt until smooth.
    +++++++++++++++++++++++++++++
    Groovie Smoothie
    2 small bananas, broken into chunks1 cup frozen unsweetened strawberries1 (8 ounce) container vanilla low-fat yogurt3/4 cup milk
    In a blender, combine bananas, frozen strawberries, yogurt and milk. Blend until smooth. Pour into glasses and serve.
  """
  def display_smoothies({_, smoothies}) do
    smoothies
    #|> Enum.each(fn s -> ResultStore.add(s) end)
    |> Enum.map(fn s ->
      IO.puts(s.name)
      IO.puts(s.ingredients)
      IO.puts(s.directions)
      IO.puts("+++++++++++++++++++++++++++++")
    end)
  end

  def store_data({_, smoothies}) do
    smoothies
    |> Enum.each(fn s -> ResultStore.add(s) end)
    {:ok, smoothies}
  end




  @doc """
  Hello world.

  ## Examples

      iex> LabCrawler.hello()
      :world

  """
  def hello do
    IO.inspect(System.get_env("prop"))
    IO.inspect(Application.fetch_env!(:some_app, :key1))
    :world
  end
end
