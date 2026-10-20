defmodule Joblite.Core.MixProject do
  use Mix.Project

  def project do
    [
      app: :joblite_core,
      version: "0.1.0",
      elixir: "~> 1.20.0",
      elixirc_paths: if(Mix.env() == :test, do: ["lib", "test/support"], else: ["lib"]),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: [
        check: ["format --check-formatted", "compile --warnings-as-errors", "credo", "test"],
        test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger, :ssl], mod: {Joblite.Application, []}]
  end

  def cli do
    [preferred_envs: [check: :test]]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.14.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_pubsub, "~> 2.2"},
      {:bcrypt_elixir, "~> 3.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
