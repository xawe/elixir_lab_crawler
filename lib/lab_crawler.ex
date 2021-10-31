defmodule LabCrawler do
  @moduledoc """
  Documentation for `LabCrawler`.
  """

  def start() do
    :timer.tc(fn -> Web.AllRecipes.get_smoothies_recipe(&ProcessServer.process/1) end)
    # get_smoothies_recipe()
  end
end
