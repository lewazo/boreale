defmodule Boreale.DomainsTest do
  use Boreale.TestCase

  alias Boreale.{Domains, Storage}

  setup do
    _ = Domains.start_link([])
    :ok
  end

  @domain "public.com"
  describe "public?/1" do
    test "only public domains are public" do
      with_mock(Storage, read_dets: fn _, _ -> [[@domain, DateTime.utc_now()]] end) do
        Domains.sync()
        assert Domains.public?(@domain)
        refute Domains.public?("another.domain.com")
      end
    end
  end

  describe "sync/0" do
    test "updates itself on sync" do
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
