defmodule HttpToSerial.Mixfile do
  use Mix.Project

  def project do
    [
      app: :http_to_serial,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      extra_applications: [:logger, :maru, :json, :nerves_uart],
      mod: {App, []}
    ]

  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:maru, "~> 0.10"},
      {:distillery, "~> 1.5"},
      {:json, "~> 1.0"},
      {:nerves_uart, "~> 0.1.2"},
      {:msgpax, "~> 2.0"},
      {:calendar, "~> 0.17.2"}, ## Not used!
      {:httpoison, "~> 1.5"}
    ]
  end
end
