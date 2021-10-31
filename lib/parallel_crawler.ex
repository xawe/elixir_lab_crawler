defmodule ParallelCrawler do

  def one_for_one() do
    :timer.tc(fn -> Web.AllRecipes.get_smoothies_recipe(&ProcessServer.process/1) end)
  end

  def run_pool(pool_count) do
    # get_smoothies_recipe(max_process)
    :timer.tc(fn ->
      Web.AllRecipes.get_smoothies_recipe(pool_count, &ProcessServer.process/2)
    end)
  end

end
