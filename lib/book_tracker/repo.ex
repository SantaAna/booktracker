defmodule BookTracker.Repo do
  use Ecto.Repo,
    otp_app: :book_tracker,
    adapter: Ecto.Adapters.Postgres
end
