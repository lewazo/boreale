defmodule Mix.Tasks.CLI.UsersRemove do
  def run(args) do
    args = Mix.Tasks.CLI.Utils.args_to_map(args)

    case args do
      %{"--help" => _} -> Mix.Tasks.CLI.Utils.print_help_for("users remove")
      x when x == %{} -> remove_user()
      _ -> IO.puts "boreale cli: users remove command does not take any arguments"
           IO.puts "See 'boreale cli users remove --help'"
    end
  end

  defp remove_user do
    users = Mix.Tasks.CLI.Users.run()

    with {:users_not_empty} <- is_users_empty?(users),
         {:ok, username} <- get_user(users)
    do
      {:ok, table} =
        File.cwd!
        |> Path.join("data/users.dets")
        |> String.to_atom()
        |> :dets.open_file([type: :set])

      deleted? = :dets.delete(table, username)
      :dets.close(table)

      case deleted? do
        :ok -> IO.puts "User #{username} has been removed."
          _ -> IO.puts "Error : User #{username} hasn't been removed."
      end
    else
      {:no_user_with_id} -> IO.puts ("Error: There is no authorized user with this ID.")
      {:users_empty} -> nil
    end
  end

  defp get_user(users) do
    users =
      Stream.map(users, fn {id, name, _} -> {id, name} end)
      |> Enum.into(%{})
    IO.puts("")
    id = IO.gets("Enter the ID of the user you wish to remove: ") |> String.trim
    if (users[id]),
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
