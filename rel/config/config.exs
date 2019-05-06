use Mix.Config

config :boreale, Boreale,
  port: System.get_env("PORT"),
  page_title: System.get_env("PAGE_TITLE")

config :boreale, Boreale.Router,
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  cookie_name: System.get_env("COOKIE_NAME"),
  signing_salt: System.get_env("SIGNING_SALT"),
  encryption_salt: System.get_env("ENCRYPTION_SALT")
