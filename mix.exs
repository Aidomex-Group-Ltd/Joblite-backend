defmodule Joblite.Core.MixProject do
  use Mix.Project

  def project do
    [
      app: :joblite_core,
      version: "0.1.0",
      elixir: "~> 1.20.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: [check: ["format --check-formatted", "compile --warnings-as-errors", "test"]]
    ]
  end

  def application do
    [extra_applications: [:logger, :ssl], mod: {Joblite.Application, []}]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.14.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_pubsub, "~> 2.2"}
    ]
  end
end
