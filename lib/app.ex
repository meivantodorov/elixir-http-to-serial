defmodule App do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      Serial
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
