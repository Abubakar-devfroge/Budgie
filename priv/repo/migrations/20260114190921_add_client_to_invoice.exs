defmodule First.Repo.Migrations.AddClientToInvoice do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :client, :string
    end
  end
end
