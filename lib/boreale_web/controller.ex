defmodule BorealeWeb.Controller do
  import Plug.Conn
  alias Boreale.Storage

  def render(%{status: status} = conn, template, assigns \\ []) do
    body =
      Storage.templates_directory_path()
      |> Path.join(template)
      |> String.replace_suffix(".html", ".html.heex")
      |> EEx.eval_file(assigns)

    send_resp(conn, status || 200, body)
  end
end
