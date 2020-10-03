use Mix.Config

config :boreale, Boreale,
  port: 4001,
  page_title: "Boréale Authentication"

config :boreale, Boreale.Router,
  secret_key_base: "C6lIRaMxBMHQxo3fpdTuFJpYRC1Sa1JPWcWbISYzV5PdgIdMFQg/9L1ih1YhTPAo",
  cookie_name: "_boreale_auth",
  signing_salt: "G2QtYcEksGCoE1ny0SSMJRomz5EZ5rZL",
  encryption_salt: "Ispbi7x6yx98R85k8/AsZnJVtK1BReyF"

config :logger, level: :info
