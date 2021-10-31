defmodule ResultStore do
  use Agent
  @moduledoc """
  Processo Supervisionado utilizado para armazenamento do resultado obtido no processamento das Urls

  """

  def start_link(initial_value \\ []) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  @doc """
  Adiciona um novo valor ao ResultStore
  """
  def add(value) do
    Agent.update(__MODULE__, &(&1 ++ [value]))
  end

  @doc """
  Retorna todos os valores armazenados no ResultStore
  """
  def all() do
    Agent.get(__MODULE__, & &1)
  end

  @doc """
  Limpa todos os valores armazenados no ResultStore
  """
  def clean() do
    Agent.update(__MODULE__, fn _ -> [] end)
  end
end
