defmodule Boreale.Storage do
  alias Boreale.User

  @spec priv_directory_path :: String.t()
  def priv_directory_path, do: :code.priv_dir(:boreale)

  @spec user_directory_path :: String.t()
  def user_directory_path do
    Path.join(priv_directory_path(), user_directory())
  end

  @spec hosted_directory_path :: String.t()
  def hosted_directory_path do
    Path.join(priv_directory_path(), hosted_directory())
  end

  @spec persisted_users_filepath :: atom()
  def persisted_users_filepath do
    user_directory_path()
    |> Path.join("users.dets")
    |> String.to_atom()
  end

  @spec persisted_domains_filepath :: atom()
  def persisted_domains_filepath do
    user_directory_path()
    |> Path.join("domains.dets")
    |> String.to_atom()
  end

  @spec get_user(String.t()) :: {:ok, User.t()} | {:error, String.t()}
  def get_user(username) do
    case lookup_table(persisted_users_filepath(), username) do
      [dets_user] -> {:ok, User.dets_user_to_struct(dets_user)}
      _ -> {:error, "Username not found"}
    end
  end

  defp lookup_table(filepath, key) do
    table = open_table(filepath)
    object = :dets.lookup(table, key)
    close_table(table)
    object
  end

  defp open_table(filepath) do
    {:ok, table} = :dets.open_file(filepath, type: :set)
    table
  end

  defp close_table(table) do
    :dets.close(table)
  end

  defp user_directory do
    Application.get_env(:boreale, __MODULE__)[:user_directory]
  end

  defp hosted_directory do
    Application.get_env(:boreale, __MODULE__)[:hosted_directory]
  end
end
