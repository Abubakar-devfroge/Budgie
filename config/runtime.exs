import Config

if config_env() == :prod do
  port = String.to_integer(System.get_env("PORT") || "8080")
  host = System.get_env("PHX_HOST") || "first-dark-sea-8115.fly.dev"

  config :first, FirstWeb.Endpoint,
    server: true,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0},
      port: port
    ],
    secret_key_base:
      System.get_env("SECRET_KEY_BASE") ||
        raise("""
        environment variable SECRET_KEY_BASE is missing.
        """)

  database_url =
    System.get_env("DATABASE_URL") ||
      raise("""
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """)

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :first, First.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  config :first, First.Mailer, api_key: System.get_env("RESEND_API_KEY")
end
