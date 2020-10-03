defmodule Boreale.UsersTest do
  use Boreale.TestCase

  alias Boreale.{Users, Storage}

  setup do
    _ = Users.start_link([])
    :ok
  end

  describe "sync/0" do
    test "syncs with latest changes" do
      assert false
    end
  end

  describe "valid?/2" do
    test "validate users" do
      assert false
    end
  end
end
