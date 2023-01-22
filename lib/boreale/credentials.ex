defmodule Boreale.Credentials do
  alias Boreale.Storage

  def user_allowed?(domain, session) do
    user_logged_in?(session) || domain_public?(domain)
  end

  def validate(username, password) do
    with {:ok, user} <- Storage.get_user(username),
         true <- Bcrypt.verify_pass(password, user.password_hash) do
      :ok
    end
  end

  defp user_logged_in?(session) do
    if username = Map.get(session, "username") do
      username = String.downcase(username)
      match?({:ok, _user}, Storage.get_user(username))
    end
  end

  defp domain_public?(domain) do
    domains = Storage.get_domains() |> Enum.map(& &1.host)
    domain in domains
  end
end
