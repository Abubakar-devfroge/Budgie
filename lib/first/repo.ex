defmodule First.Repo do
  use Ecto.Repo,
    otp_app: :first,
    adapter: Ecto.Adapters.SQLite3
end
