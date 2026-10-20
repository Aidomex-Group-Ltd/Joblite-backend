defmodule Joblite.Health do
  @moduledoc "Small public boundary for runtime metadata and database readiness."

  @spec architecture() :: map()
  def architecture do
    %{ui: "Phoenix LiveView", database: "PostgreSQL", runtime: "one release"}
  end

  @spec readiness() :: :ok | {:error, :database_unavailable}
  def readiness do
    if Process.whereis(Joblite.Repo), do: check_database(), else: unavailable()
  end

  defp check_database do
    case Ecto.Adapters.SQL.query(Joblite.Repo, "SELECT 1", [], timeout: 2_000) do
      {:ok, _result} -> :ok
      {:error, _reason} -> unavailable()
    end
  rescue
    DBConnection.ConnectionError -> unavailable()
  catch
    :exit, _reason -> unavailable()
  end

  defp unavailable, do: {:error, :database_unavailable}
end
