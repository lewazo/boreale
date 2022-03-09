import Config

config :boreale, Boreale.Storage,
  user_directory: "data",
  hosted_directory: "static"

import_config "#{Mix.env()}.exs"
