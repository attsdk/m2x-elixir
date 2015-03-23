defmodule M2X.Mixfile do
  use Mix.Project

  def version, do: "0.0.1"

  def project do
    [ app:     :m2x,
      version: version,
      elixir:  "~> 1.0",
      deps:    deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:logger] ]
  end

  # Dependencies
  defp deps do
    [ hackney: "~> 1.0",
      json:    "~> 0.3" ]
  end
end
