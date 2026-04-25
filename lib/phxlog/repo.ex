defmodule Phxlog.Repo do
  use Ecto.Repo,
    otp_app: :phxlog,
    adapter: Ecto.Adapters.Postgres
end
