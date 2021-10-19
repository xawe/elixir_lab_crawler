defmodule LabCrawler do
  @moduledoc """
  Documentation for `LabCrawler`.
  """

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
