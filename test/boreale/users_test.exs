defmodule Boreale.UsersTest do
  use Boreale.TestCase

  alias Boreale.{Users, Storage}

  setup do
    _ = Users.start_link([])
    :ok
  end

  @valid_user "valid_user"
  @password "password"
  @valid_users [
    [@valid_user, @password, DateTime.utc_now()]
  ]
  describe "sync/0" do
    test "syncs with latest changes" do
      with_mock(Storage, read_dets: fn _, _ -> [] end) do
        Users.sync()
        refute Users.valid?(@valid_user, @password)
      end

      with_mock(Storage, read_dets: fn _, _ -> hash_user_passwords(@valid_users) end) do
        Users.sync()
        assert Users.valid?(@valid_user, @password)
      end
    end
  end

  describe "valid?/2" do
    test "validate users" do
      with_mock(Storage, read_dets: fn _, _ -> hash_user_passwords(@valid_users) end) do
        Users.sync()
        assert Users.valid?(@valid_user, @password)
        refute Users.valid?(@valid_user, "bad_password")
        refute Users.valid?("invalid_user", @password)
      end
    end

    test "return false if no users exists" do
      with_mock(Storage, read_dets: fn _, _ -> [] end) do
        Users.sync()
        refute Users.valid?(@valid_user, @password)
        refute Users.valid?(@valid_user, "bad_password")
        refute Users.valid?("invalid_user", @password)
      end
    end
  end

  defp hash_user_passwords(users) do
    Enum.map(users, fn [user, pw, date] ->
      [user, Bcrypt.hash_pwd_salt(pw), date]
    end)
  end
end
