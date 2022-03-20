defmodule Boreale.Storage do
  alias Boreale.{Domain, User}

  @spec user_directory_path :: String.t()
  def user_directory_path do
    Application.get_env(:boreale, __MODULE__)[:user_directory]
  end

  @spec default_directory_path :: String.t()
  def default_directory_path do
    Application.get_env(:boreale, __MODULE__)[:default_directory]
    |> get_app_dir()
  end

  @spec templates_directory_path :: String.t()
  def templates_directory_path do
    Application.get_env(:boreale, __MODULE__)[:templates_directory]
    |> get_app_dir()
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

  @spec get_domains() :: list(String.t())
  def get_domains do
    persisted_domains_filepath()
    |> list_table()
    |> Domain.dets_domain_to_struct()
  end

  defp get_app_dir(filepath) do
    Application.app_dir(:boreale, filepath)
  end

  defp lookup_table(filepath, key) do
    table = open_table(filepath)
    object = :dets.lookup(table, key)
    close_table(table)
    object
  end

  defp list_table(filepath) do
    table = open_table(filepath)
    objects = :dets.match(table, {:"$1", :"$2"})
    close_table(table)
    objects
  end

  defp open_table(filepath) do
    {:ok, table} = :dets.open_file(filepath, type: :set)
    table
  end

  defp close_table(table) do
    :dets.close(table)
  end
end
