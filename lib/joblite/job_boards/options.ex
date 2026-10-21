defmodule Joblite.JobBoards.Options do
  @moduledoc """
  The vocabulary for the directory screen.
  """
  alias Joblite.JobBoards.{Category, Region}

  @doc "The vocabulary the directory screen needs to render its filters."
  @spec directory() :: map()
  def directory do
    %{
      regions: Enum.map(Region.regions(), &%{value: Atom.to_string(&1), label: Region.label(&1)}),
      categories:
        Enum.map(Category.categories(), &%{value: Atom.to_string(&1), label: Category.label(&1)})
    }
  end
end
