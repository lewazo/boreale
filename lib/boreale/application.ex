defmodule Boreale.Application do
  use Application

  alias Boreale.SSL

  def start(_type, _args) do
    SSL.generate_cert()

    children = [
      Plug.Cowboy.child_spec(
        scheme: :https,
        plug: Boreale.Router,
        options: [
          port: Application.get_env(:boreale, Boreale)[:port],
          keyfile: SSL.key_file(),
          certfile: SSL.cert_file()
        ]
      ),
      Boreale.Domains
    ]

    opts = [strategy: :one_for_one, name: Boreale.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
