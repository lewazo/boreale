defmodule Boreale.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

  plug Plug.SSL, hsts: false
  plug Plug.Logger, log: :debug
  plug :put_secret_key_base
  plug :session

  plug :match
  plug :dispatch

  get "/" do
    Boreale.LoginController.index(conn)
  end

  # When not behind the traefik reverse-proxy, we need a route for POST.
  # This is because traefik transforms our POST request to a GET request.
  # This is used for testing purposes.
  post "/" do
    Boreale.LoginController.index(conn)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp put_secret_key_base(conn, _) do
    put_in conn.secret_key_base, Application.get_env(:boreale, Boreale.Router)[:secret_key_base]
  end

  defp session(conn, _opts) do
    opts =
      Plug.Session.init(
        store: :cookie,
        key: Application.get_env(:boreale, Boreale.Router)[:cookie_name],
        signing_salt: Application.get_env(:boreale, Boreale.Router)[:signing_salt],
        encryption_salt: Application.get_env(:boreale, Boreale.Router)[:encryption_salt],
        secure: true
      )

    Plug.Session.call(conn, opts)
  end
end
