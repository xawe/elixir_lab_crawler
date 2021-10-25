defmodule LabCrawler2 do
  @moduledoc """
  Documentation for `LabCrawler2`.
  """

  def start(max_process) do
    #get_smoothies_recipe(max_process)
    :timer.tc(fn -> get_smoothies_recipe(max_process) end)
  end


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

  def get_smoothies_recipe(max_process) do
    {status, urls} = read_main_url()
    Caller2.process(urls, max_process)
    {:created, status}
  end


  def hello do
    IO.inspect(System.get_env("prop"))
    IO.inspect(Application.fetch_env!(:some_app, :key1))
    :world
  end
end