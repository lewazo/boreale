defmodule Boreale.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Boreale.SSL

  require Logger

  @impl true
  def start(_type, _args) do
    SSL.maybe_generate_certificate()

    children = [
      {Plug.Cowboy,
       scheme: :https,
       plug: BorealeWeb.Router,
       port: port(),
       otp_app: :boreale,
       keyfile: SSL.get_key_path(),
       certfile: SSL.get_certificate_path()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Boreale.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    Logger.info("Boreale server started on https://localhost:#{port()}")

    {:ok, pid}
  end

  defp port do
    Application.get_env(:boreale, BorealeWeb.Router)[:port]
  end
end
