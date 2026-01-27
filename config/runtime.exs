import Config

if config_env() == :prod do
  # Force Phoenix server to start
  config :first, FirstWeb.Endpoint, server: true

  # DATABASE
  database_url =
    System.get_env("DATABASE_URL") ||
      raise "DATABASE_URL is missing!"

  ssl_enabled = System.get_env("DB_SSL") == "true"

  ssl_opts =
    if ssl_enabled, do: [verify: :verify_none], else: []

  config :first, First.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "15"),
    ssl: ssl_enabled,
    ssl_opts: ssl_opts,
    queue_target: 5000,
    queue_interval: 1000

  # SECRET KEY
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "SECRET_KEY_BASE is missing!"

  # PHX HOST
  host = System.get_env("PHX_HOST") || "first-dark-sea-8115.fly.dev"

  config :first, FirstWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base
end
