defmodule Boreale.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Boreale.{Assets, SSL}

  @impl true
  def start(_type, _args) do
    init_boreale_server()

    children = [
      {Plug.Cowboy,
       scheme: :https,
       plug: BorealeWeb.Router,
       options: [port: port()],
       keyfile: SSL.get_key_path(),
       certfile: SSL.get_certificate_path()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Boreale.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp init_boreale_server do
    SSL.maybe_generate_certificate()
    Assets.prepare_static_assets()
  end

  defp port do
    Application.get_env(:boreale, BorealeWeb.Router)[:port]
  end
end
