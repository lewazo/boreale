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
    Map.has_key?(session, "username")
  end

  defp domain_public?(_domain) do
    false
  end
end
