defmodule Boreale.Plug.ParseRequest do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> parse_params()
    |> fetch_session_cookie()
    |> get_forwarded_domain()
  end

  defp parse_params(conn) do
    case get_req_header(conn, "auth-form") do
      [] ->
        conn
        |> assign(:action, :index)

      [value] ->
        %{"username" => username, "password" => password} = URI.decode_query(value)

        conn
        |> assign(:action, :login)
        |> assign(:username, username)
        |> assign(:password, password)
    end
  end

  defp fetch_session_cookie(conn) do
    conn = fetch_session(conn)
    session = get_session(conn)
    assign(conn, :session, session)
  end

  defp get_forwarded_domain(conn) do
    domain =
      case get_req_header(conn, "x-forwarded-host") do
        [] -> nil
        [domain] -> domain
      end

    assign(conn, :domain, domain)
  end
end
