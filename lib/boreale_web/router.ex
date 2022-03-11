defmodule BorealeWeb.Router do
  use Plug.Router

  alias BorealeWeb.Login.Controller, as: LoginController

  # Plug configuration
  plug Plug.SSL, hsts: false
  plug Plug.Logger, log: :debug
  plug Plug.Parsers, parsers: [:urlencoded]

  plug Boreale.Plug.InitSession
  plug Boreale.Plug.ParseRequest

  plug :match
  plug :dispatch

  get "/" do
    LoginController.index(conn)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
