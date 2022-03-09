defmodule Boreale.Plug.ParseRequest do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> get_action()
    |> fetch_session_cookie()
    |> get_forwarded_domain()
  end

  defp get_action(conn) do
    action = if conn.params["action"] == "login", do: :login, else: :index
    assign(conn, :action, action)
  end

  defp fetch_session_cookie(conn) do
    conn = fetch_session(conn)
    session = get_session(conn)
    assign(conn, :session, session)
  end

  defp get_forwarded_domain(conn) do
    domain = get_req_header(conn, "x-forwarded-host")
    assign(conn, :domain, domain)
  end
end
