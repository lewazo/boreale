defmodule Boreale.Uusers do
  @users_file "data/users.dets"

  defp all do
    {:ok, table} =
      File.cwd!()
      |> Path.join(@users_file)
      |> String.to_atom()
      |> :dets.open_file(type: :set)

    :dets.match(table, {:"$1", :"$2", :"$3"})
    |> Enum.map(fn x -> List.to_tuple(x) end)
    |> Enum.map(fn {u, pw, _} -> {u, pw} end)
    |> Enum.into(%{})
  end

  def valid?(user, password) do
    password_hash = Map.get(all(), user, nil)

    not is_nil(password_hash) and Bcrypt.verify_pass(password, password_hash)
  end
end
