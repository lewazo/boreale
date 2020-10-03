defmodule Boreale.RouterTest do
  use Boreale.ConnCase

  describe "GET /" do
    setup do
      conn =
        :get
        |> conn("/")
        |> Map.put(:scheme, :https)

      %{conn: conn}
    end

    @public_domain "public.com"
    @domain_header "x-forwarded-host"
    test "renders login on any non-public domains", %{conn: conn} do
      with_mock(Boreale.Domains, domains_mock()) do
        conn =
          conn
          |> put_req_header(@domain_header, "private.com")
          |> Boreale.Router.call(%{})

        assert conn.status == 401
        assert conn.resp_body =~ "Login"
      end
    end

    test "redirects when domain is public", %{conn: conn} do
      with_mock(Boreale.Domains, domains_mock()) do
        conn =
          conn
          |> put_req_header(@domain_header, @public_domain)
          |> Boreale.Router.call(%{})

        assert conn.status == 200
        assert conn.resp_body == "authorized"
      end
    end

    test "redirects when authenticated", %{conn: conn} do
      with_mock(Boreale.Domains, domains_mock()) do
        conn =
          conn
          |> put_req_header(@domain_header, "private.com")
          |> init_test_session(%{"username" => "user@email.com"})
          |> Boreale.Router.call(%{})

        assert conn.status == 200
        assert conn.resp_body == "authorized"
      end
    end
  end

  describe "POST /" do
    setup do
      conn =
        :post
        |> conn("/")
        |> Map.put(:scheme, :https)

      %{conn: conn}
    end

    @auth_form "auth-form"
    @good_creds URI.encode_query(%{
                  "action" => "login",
                  "username" => "user@email.com",
                  "password" => "secret"
                })
    test "login a user successfully", %{conn: conn} do
      with_mock(Boreale.Users, users_mock()) do
        conn =
          conn
          |> put_req_header(@domain_header, "private.com")
          |> put_req_header(@auth_form, @good_creds)
          |> Boreale.Router.call(%{})

        assert conn.status == 300
      end
    end

    @bad_creds URI.encode_query(%{
                 "action" => "login",
                 "username" => "user@email.com",
                 "password" => "bad_password"
               })
    test "does not login a user with bad password", %{conn: conn} do
      with_mock(Boreale.Users, users_mock()) do
        conn =
          conn
          |> put_req_header(@domain_header, "private.com")
          |> put_req_header(@auth_form, @bad_creds)
          |> Boreale.Router.call(%{})

        assert conn.status == 401
        assert conn.resp_body =~ "Wrong username or password"
      end
    end
  end

  defp domains_mock, do: [public?: fn public -> public in [@public_domain] end]

  @users %{"user@email.com" => "secret"}
  defp users_mock do
    [
      valid?: fn username, password -> Map.get(@users, username) == password end
    ]
  end
end
