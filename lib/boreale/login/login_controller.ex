defmodule Boreale.LoginController do
  import Plug.Conn

  alias Boreale.{Domains, Users}

  def index(conn) do
    with {:index} <- action?(conn),
         {:private_domain} <- is_domain_public(conn),
         {:not_logged_in} <- is_logged_in(conn) do
      body = EEx.eval_file(Application.app_dir(:boreale, "priv/login.html.eex"))
      send_resp(conn, 401, body)
    else
      {:login} -> login(conn)
      _ -> send_resp(conn, 200, "authorized")
    end
  end

  defp login(conn) do
    with {:ok, username, password} <- get_params(conn),
         :ok <- validate_credentials(username, password) do
      conn
      |> fetch_session
      |> put_session("username", username)
      |> send_resp(300, "Multiple choices")
    else
      _ -> send_resp(conn, 401, "Wrong username or password.")
    end
  end

  defp action?(conn) do
    headers = Enum.into(conn.req_headers, %{})

    case headers["auth-form"] do
      nil ->
        {:index}

      authform ->
        %{"action" => "login"} = URI.decode_query(authform)
        {:login}
    end
  end

  defp get_params(conn) do
    headers = Enum.into(conn.req_headers, %{})

    case headers["auth-form"] do
      nil ->
        {:error}

      authform ->
        %{"username" => username, "password" => password} = URI.decode_query(authform)
        {:ok, username, password}
    end
  end

  defp validate_credentials(username, password) do
    if Users.valid?(username, password), do: :ok, else: :error
  end

  defp is_logged_in(conn) do
    case conn |> fetch_session() |> get_session() do
      %{"username" => _username} -> {:logged_in}
      _ -> {:not_logged_in}
    end
  end

  defp is_domain_public(conn) do
    headers = Enum.into(conn.req_headers, %{})

    if Domains.public?(headers["x-forwarded-host"]),
      do: {:public_domain},
      else: {:private_domain}
  end
end
