import Config

defmodule Environment do
  def get(key), do: System.get_env(key)

  def get_integer(key) do
    case get(key) do
      value when is_bitstring(value) -> String.to_integer(value)
      _ -> nil
    end
  end
end

config :boreale, BorealeWeb.Router,
  cookie_name: Environment.get("COOKIE_NAME") || "_boreale_auth",
  encryption_salt: Environment.get("ENCRYPTION_SALT"),
  port: Environment.get_integer("PORT") || 4000,
  secret_key_base: Environment.get("SECRET_KEY_BASE"),
  signing_salt: Environment.get("SIGNING_SALT"),
  sso_domain_name: Environment.get("SSO_DOMAIN_NAME")

config :boreale, BorealeWeb.Login.Controller,
  page_title: Environment.get("PAGE_TITLE") || "Boréale Authentication"
