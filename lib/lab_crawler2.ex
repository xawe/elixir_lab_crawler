defmodule LabCrawler2 do
  @moduledoc """
  Documentation for `LabCrawler2`.
  """

  def start(max_process) do
    # get_smoothies_recipe(max_process)
    :timer.tc(fn ->
      WebShredder.AllRecipes.get_smoothies_recipe(max_process, &Caller2.process/2)
    end)
  end

  def get_smoothies_recipe(max_process) do
    {status, urls} = WebShredder.AllRecipes.read_main_url()
    Caller2.process(urls, max_process)
    {:created, status}
  end

  def hello do
    IO.inspect(System.get_env("prop"))
    IO.inspect(Application.fetch_env!(:some_app, :key1))
    :world
  end
end
