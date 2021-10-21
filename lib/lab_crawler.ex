defmodule LabCrawler do
  @moduledoc """
  Documentation for `LabCrawler`.
  """

  def start() do
    :timer.tc(fn -> get_smoothies_recipe() end)
    #get_smoothies_recipe()

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
    {status, urls} = get_smoothies_url()
    Enum.each(urls, fn u -> Caller.process(u) end)

    {:created}
  end


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




  def hello do
    IO.inspect(System.get_env("prop"))
    IO.inspect(Application.fetch_env!(:some_app, :key1))
    :world
  end
end
