defmodule BorealeWeb.Login.Controller do
  import Plug.Conn

  alias Boreale.{Credentials, Storage}

  @page_body_filename "login.html"

  def index(%{assigns: %{action: :login}} = conn) do
    %{"username" => username, "password" => password} = conn.params

    case Credentials.validate(username, password) do
      :ok ->
        conn
        |> put_session("username", username)
        |> send_resp(300, "Multiple choices")

      _ ->
        conn
        |> clear_session()
        |> send_resp(401, "Wrong username or password.")
    end
  end

  def index(%{assigns: %{action: :index}} = conn) do
    %{domain: domain, session: session} = conn.assigns

    if Credentials.user_allowed?(domain, session) do
      send_resp(conn, 200, "authorized")
    else
      send_resp(conn, 401, get_page_html())
    end
  end

  defp page_assigns do
    [
      title: Application.get_env(:boreale, __MODULE__)[:page_title],
      body: get_page_body()
    ]
  end

  defp get_page_html do
    :boreale
    |> Application.app_dir("priv/login.html.heex")
    |> EEx.eval_file(page_assigns())
  end

  defp get_page_body do
    user_page_body_filepath = Path.join(Storage.user_directory_path(), @page_body_filename)

    case File.read(user_page_body_filepath) do
      {:ok, binary} ->
        binary

      _ ->
        Storage.priv_directory_path()
        |> Path.join(@page_body_filename)
        |> File.read!()
    end
  end
end
