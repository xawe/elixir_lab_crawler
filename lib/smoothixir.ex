defmodule Smoothixir do
  @moduledoc """
  Documentation for `Smoothixir`.
  """

  def start() do
    :timer.tc(fn -> start_process() end)
  end

  def start_process() do
    Smoothixir.get_smoothies_recipe()
    |> Smoothixir.store_data()
    |> Smoothixir.display_smoothies()
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
    # |> Floki.find("div#main-header")
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
    # |> Floki.text()
    # |> Floki.attribute("label", "title")
    |> Floki.text(sep: "+")
    |> String.split("+")
  end

  @doc """
  Allow you to find the directions of a smoothie within a page's html body.
  returns an Array of Strings.
  ## Examples
    iex> Smoothixir.get_smoothie_directions(body)
    ["In a blender, combine strawberries, orange juice, ice cubes and sugar. Blend until smooth. Pour into glasses and serve."]
  """
  def get_smoothie_directions(body) do
    # |> Floki.parse_document!()
    # |> Floki.find("label.checkbox-list")
    body
    |> Floki.parse_document!()
    |> Floki.find("div.paragraph")

    # |> Floki.find("span.recipe-directions__list--item")
    |> Floki.text(sep: "=>")
    |> String.split("=>")
  end

  def get_smoothies_html_body({_, urls}) do
    urls
    |> Enum.map(fn url -> HTTPoison.get(url) end)
    |> Enum.map(fn {_, result} -> result.body end)
  end

  @doc """
  This is the main function of the module.
  It gathers all the previous functions and outputs a List of Maps of smoothies with name, ingredients, directions for each of them.
  ## Examples
     iex> Smoothixir.get_smoothies_recipe()
     {:ok,
       [%{
          directions: ["Cut banana into small pieces and place into the bowl of a blender.  Add the soy milk, yogurt, flax seed meal, and honey.  Blend on lowest speed until smooth, about 5 seconds.  Gradually add the blueberries while continuing to blend on low.  Once the blueberries have been incorporated, increase speed, and blend to desired consistency.                            "],
          ingredients: ["1 frozen banana, thawed for 10 to 15 minutes",
           "1/2 cup vanilla soy milk", "1 cup vanilla fat-free yogurt",
           "1 1/2 teaspoons flax seed meal", "1 1/2 teaspoons honey",
           "2/3 cup frozen blueberries"],
          name: "Heavenly Blueberry Smoothie"
        }
      ]}
  """
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

  def display_smoothies({_, smoothies}) do
    smoothies
    # |> Enum.each(fn s -> ResultStore.add(s) end)
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
end
