defmodule Boreale.MixProject do
  use Mix.Project

  def project do
    [
      app: :boreale,
      version: "1.3.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Boreale.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:credo, "~> 1.6"},
      {:plug_cowboy, "~> 2.5"}
    ]
  end

  defp releases do
    [
      boreale: [
        version: {:from_app, :boreale},
        applications: [boreale: :permanent],
        include_executables_for: [:unix],
        steps: [:assemble, :tar]
      ]
    ]
  end
end
