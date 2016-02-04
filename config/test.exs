use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :el_mascarar, ElMascarar.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :el_mascarar, ElMascarar.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "el_mascarar_test",
  pool: Ecto.Adapters.SQL.Sandbox
