defmodule Boreale.Plug.InitSession do
  alias BorealeWeb.Router

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_secret_key_base()
    |> init_session_cookie()
  end

  defp put_secret_key_base(conn) do
    Map.put(conn, :secret_key_base, Application.get_env(:boreale, Router)[:secret_key_base])
  end

  defp init_session_cookie(conn) do
    opts =
      Plug.Session.init(
        store: :cookie,
        domain: Application.get_env(:boreale, Router)[:sso_domain_name],
        key: Application.get_env(:boreale, Router)[:cookie_name],
        signing_salt: Application.get_env(:boreale, Router)[:signing_salt],
        encryption_salt: Application.get_env(:boreale, Router)[:encryption_salt],
        secure: true
      )

    Plug.Session.call(conn, opts)
  end
end
