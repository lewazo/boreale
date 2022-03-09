defmodule Boreale.User do
  alias __MODULE__

  defstruct username: nil, password_hash: nil, created_at: nil

  def dets_user_to_struct({username, password_hash, created_at}) do
    %User{
      username: username,
      password_hash: password_hash,
      created_at: created_at
    }
  end
end
