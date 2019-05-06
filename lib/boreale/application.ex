defmodule Boreale.Application do
  use Application

  def start(_type, _args) do
    generate_ssl_cert()

    children = [
      Plug.Cowboy.child_spec(
        scheme: :https,
        plug: Boreale.Router,
        options: [
          port: String.to_integer(Application.get_env(:boreale, Boreale)[:port] || "4000"),
          keyfile: File.cwd! |> Path.join("data/key.pem"),
          certfile: File.cwd! |> Path.join("data/cert.pem")
        ]
      )
    ]

    opts = [strategy: :one_for_one, name: Boreale.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # The cert is only used for completing the SSL connection between traefik and the cowboy server
  # It does not need to be signed by an authority since the auth server is not meant to be accessed
  # directly by an hostname.
  def generate_ssl_cert do
    File.mkdir(File.cwd! |> Path.join("data"))

    if not (File.cwd! |> Path.join("data/cert.pem") |> File.exists?) do
      System.cmd("openssl", [
        "req",
        "-new",
        "-newkey", "rsa:4096",
        "-days", "365",
        "-nodes",
        "-x509",
        "-subj", "/C=US/ST=Denial/L=Springfield/O=Dis/CN=localhost",
        "-keyout", File.cwd! |> Path.join("data/key.pem"),
        "-out", File.cwd! |> Path.join("data/cert.pem")])
    end
  end
end
