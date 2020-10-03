use Mix.Config

config :boreale, Boreale,
  port: String.to_integer(System.get_env("PORT") || "4000"),
  page_title: System.get_env("PAGE_TITLE") || "Boréale Authentication"

config :boreale, Boreale.Router,
  secret_key_base:
    System.get_env("SECRET_KEY_BASE") ||
      "C6lIRaMxBMHQxo3fpdTuFJpYRC1Sa1JPWcWbISYzV5PdgIdMFQg/9L1ih1YhTPAo",
  cookie_name: System.get_env("COOKIE_NAME") || "_boreale_auth",
  signing_salt: System.get_env("SIGNING_SALT") || "G2QtYcEksGCoE1ny0SSMJRomz5EZ5rZL",
  encryption_salt: System.get_env("ENCRYPTION_SALT") || "Ispbi7x6yx98R85k8/AsZnJVtK1BReyF",
  sso_domain_name: System.get_env("SSO_DOMAIN_NAME")
