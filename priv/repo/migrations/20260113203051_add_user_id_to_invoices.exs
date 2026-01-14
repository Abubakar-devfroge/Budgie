defmodule First.Repo.Migrations.AddUserIdToInvoices do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :user_id, references(:users, on_delete: :nothing)
    end

    create index(:invoices, [:user_id])
  end
end
