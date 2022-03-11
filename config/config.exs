import Config

config :boreale, Boreale.Storage,
  user_directory: "/opt/app/data",
  default_directory: "priv/default",
  hosted_directory: "priv/static",
  templates_directory: "priv/templates"

import_config "#{Mix.env()}.exs"
