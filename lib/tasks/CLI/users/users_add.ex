defmodule Boreale.Tasks.Cli.UsersAdd do
  alias Boreale.Storage
  alias Boreale.Tasks.Cli

  def run(args) do
    args = Cli.Utils.args_to_map(args)

    case args do
      %{"--help" => _} ->
        Cli.Utils.print_help_for("users add")

      %{} ->
        add_user()

      _ ->
        IO.puts("boreale cli: users add command does not take any arguments")
        IO.puts("See 'boreale cli users add --help'")
    end
  end

  defp add_user do
    username = IO.gets("username: ") |> String.trim()
    password = password_prompt("password:") |> String.trim()

    if String.length(username) >= 3 and String.length(password) >= 6 do
      case insert_user({username, password}) do
        {:error, message} -> IO.puts(message)
        _ -> IO.puts("User #{username} has been added.")
      end
    else
      IO.puts("Username have to be at least three characters long.")
      IO.puts("Password have to be at least six characters long.")
    end
  end

  defp insert_user({username, password}) do
    date_time = DateTime.utc_now()

    {:ok, table} = :dets.open_file(Storage.persisted_users_filepath(), type: :set)

    hashed_password = Bcrypt.hash_pwd_salt(password)
    created? = :dets.insert_new(table, {username, hashed_password, date_time})

    :dets.close(table)

    if created? do
      :ok
    else
      {:error, "The user #{username} already exists."}
    end
  end

  # Password prompt that hides input by every 1ms
  # clearing the line with stderr
  #
  # taken from the hex repository
  # https://github.com/hexpm/hex/blob/ae70158bb7c96f2d95b15c5b64c1899f8188e2d8/lib/mix/tasks/hex.ex#L363
  defp password_prompt(prompt) do
    pid = spawn_link(fn -> clear_password(prompt) end)
    ref = make_ref()
    value = IO.gets(prompt <> " ")

    send(pid, {:done, self(), ref})
    receive do: ({:done, ^pid, ^ref} -> :ok)

    value
  end

  defp clear_password(prompt) do
    receive do
      {:done, parent, ref} ->
        send(parent, {:done, self(), ref})
        IO.write(:standard_error, "\e[2K\r")
    after
      1 ->
        IO.write(:standard_error, "\e[2K\r#{prompt} ")
        clear_password(prompt)
    end
  end
end
