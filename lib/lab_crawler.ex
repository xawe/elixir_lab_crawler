defmodule LabCrawler do
  @moduledoc """
  Documentation for `LabCrawler`.
  """

  def start() do
    :timer.tc(fn -> Web.AllRecipes.get_smoothies_recipe(&Caller2.process/1) end)
    # get_smoothies_recipe()
  end

  # def get_smoothies_url() do
  #   case HTTPoison.get(
  #          "https://www.allrecipes.com/recipes/138/drinks/smoothies/?internalSource=hubcard&referringContentType=Search&clickId=cardslot%201"
  #        ) do
  #     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
  #       urls =
  #         body
  #         |> Floki.parse_document!()
  #         |> Floki.find("a.card__titleLink")
  #         |> Floki.attribute("href")

  #       {:ok, urls}

  #     {:ok, %HTTPoison.Response{status_code: 404}} ->
  #       IO.puts("Not found :(")

  #     {:error, %HTTPoison.Error{reason: reason}} ->
  #       IO.inspect(reason)
  #   end
  # end

  # def get_smoothies_recipe() do
  #   {status, urls} = get_smoothies_url()
  #   Enum.each(urls, fn u -> Caller.process(u) end)
  #   {:created, status}
  # end

  # def store_data({_, smoothies}) do
  #   smoothies
  #   |> Enum.each(fn s -> ResultStore.add(s) end)

  #   {:ok, smoothies}
  # end


end
