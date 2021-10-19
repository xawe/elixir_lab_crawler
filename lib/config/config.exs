import Config

config :lab_crawler,
 prop: "10"

 import_config "#{config.env()}.exs"
