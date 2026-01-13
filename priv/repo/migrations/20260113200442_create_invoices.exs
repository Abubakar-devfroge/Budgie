defmodule First.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :invoice_number, :string
      add :amount, :decimal, null: false
      add :status, :string, default: "not paid"
      add :issued_at, :utc_datetime

      # Add user_id inside the table block
      add :user_id, references(:users), null: false

      timestamps()
    end

    # Indexes
    create index(:invoices, [:user_id])
    create unique_index(:invoices, [:invoice_number])
  end
end
