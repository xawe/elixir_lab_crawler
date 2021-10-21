defmodule ResultStore do
  use Agent

  def start_link(initial_value \\ []) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def add(value) do
    Agent.update(__MODULE__, &(&1 ++ [value]))
  end

  def all() do
    Agent.get(__MODULE__, & &1)
  end

end
