defmodule LabCrawler2 do
  @moduledoc """
  Documentation for `LabCrawler`.
  """

  def start(max_process) do
    :timer.tc(fn -> get_smoothies_recipe() end)
    # get_smoothies_recipe()
  end

  def start_caller_process(max_proces) do
    Enum.map(1..max_proces, fn _ -> DynamicSupervisor.start_child(DynamicCaller, Caller2) end)

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

  def get_smoothies_recipe() do
    {status, urls} = get_smoothies_url()
    Enum.each(urls, fn u -> Caller.process(u) end)
    {:created, status}
  end


  def hello do
    IO.inspect(System.get_env("prop"))
    IO.inspect(Application.fetch_env!(:some_app, :key1))
    :world
  end
end
