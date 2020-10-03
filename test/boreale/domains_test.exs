defmodule Boreale.DomainsTest do
  use Boreale.TestCase

  alias Boreale.{Domains, Storage}

  describe "start_link/1" do
    setup do
      _ = Domains.start_link([])
      :ok
    end

    @domain "public.com"
    test "syncs with dets content" do
      with_mock(Storage, read_dets: fn _, _ -> [] end) do
        Domains.sync()
        refute Domains.public?(@domain)
      end

      with_mock(Storage, read_dets: fn _, _ -> [[@domain, DateTime.utc_now()]] end) do
        Domains.sync()
        assert Domains.public?(@domain)
        refute Domains.public?("another.domain.com")
      end
    end
  end
end
