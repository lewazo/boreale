defmodule BorealeWeb.Login.Controller do
  import BorealeWeb.Controller
  import Plug.Conn

  alias Boreale.{Credentials, Storage}

  @page_body_filename "login.html"
  @page_style_filename "login.css"

  def index(%{assigns: %{action: :index}} = conn) do
    %{domain: domain, session: session} = conn.assigns

    if Credentials.user_allowed?(domain, session) do
      send_resp(conn, 200, "authorized")
    else
      conn
      |> put_status(401)
      |> render("login.html", page_assigns())
    end
  end

  def index(%{assigns: %{action: :login}} = conn) do
    %{username: username, password: password} = conn.assigns

    username = String.downcase(username)

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

  defp page_assigns do
    [
      title: Application.get_env(:boreale, __MODULE__)[:page_title],
      body: get_page_body(),
      style: get_page_style()
    ]
  end

  defp get_page_body do
    get_file(@page_body_filename)
  end

  defp get_page_style do
    get_file(@page_style_filename)
  end

  defp get_file(filename) do
    user_filepath = Path.join(Storage.user_directory_path(), filename)

    case File.read(user_filepath) do
      {:ok, binary} ->
        binary

      _ ->
        path = Path.join(Storage.user_directory_path(), filename)

        if File.exists?(path) do
          File.read!(path)
        else
          Storage.default_directory_path()
          |> Path.join(filename)
          |> File.read!()
        end
    end
  end
end
