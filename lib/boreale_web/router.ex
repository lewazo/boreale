defmodule BorealeWeb.Router do
  use Plug.Router

  alias BorealeWeb.Login.Controller, as: LoginController

  # Plug configuration
  plug Plug.SSL, hsts: false
  plug Plug.Logger, log: :debug
  plug Plug.Static, at: "/assets", from: {:boreale, "priv/static"}
  plug Plug.Parsers, parsers: [:urlencoded]

  plug Boreale.Plug.InitSession
  plug Boreale.Plug.ParseRequest

  plug :match
  plug :dispatch

  get "/" do
    LoginController.index(conn)
  end

  # When not behind the traefik reverse-proxy, we need a route for POST.
  # This is because traefik transforms our POST request to a GET request.
  # This is used for testing purposes.
  if Mix.env() == :dev do
    post "/" do
      LoginController.index(conn)
    end
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
