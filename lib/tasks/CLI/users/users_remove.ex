defmodule Boreale.Tasks.Cli.UsersRemove do
  alias Boreale.Storage
  alias Boreale.Tasks.Cli

  def run(args) do
    args = Cli.Utils.args_to_map(args)

    case args do
      %{"--help" => _} ->
        Cli.Utils.print_help_for("users remove")

      %{} ->
        remove_user()

      _ ->
        IO.puts("boreale cli: users remove command does not take any arguments")
        IO.puts("See 'boreale cli users remove --help'")
    end
  end

  defp remove_user do
    users = Cli.Users.run()

    with {:users_not_empty} <- is_users_empty?(users),
         {:ok, username} <- get_user(users) do
      {:ok, table} = :dets.open_file(Storage.persisted_users_filepath(), type: :set)

      deleted? = :dets.delete(table, username)
      :dets.close(table)

      case deleted? do
        :ok -> IO.puts("User #{username} has been removed.")
        _ -> IO.puts("Error : User #{username} hasn't been removed.")
      end
    else
      {:no_user_with_id} -> IO.puts("Error: There is no authorized user with this ID.")
      {:users_empty} -> nil
    end
  end

  defp get_user(users) do
    users =
      Stream.map(users, fn {id, name, _} -> {id, name} end)
      |> Enum.into(%{})

    IO.puts("")
    id = IO.gets("Enter the ID of the user you wish to remove: ") |> String.trim()

    if users[id],
      do: {:ok, users[id]},
      else: {:no_user_with_id}
  end

  defp is_users_empty?(users) do
    case is_nil(users) do
      true -> {:users_empty}
      false -> {:users_not_empty}
    end
  end
end
