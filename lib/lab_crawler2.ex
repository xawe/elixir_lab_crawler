defmodule LabCrawler2 do
  @moduledoc """
  Documentation for `LabCrawler2`.
  """

  def start(max_process) do
    # get_smoothies_recipe(max_process)
    :timer.tc(fn ->
      Web.AllRecipes.get_smoothies_recipe(max_process, &ProcessServer.process/2)
    end)
  end

end
