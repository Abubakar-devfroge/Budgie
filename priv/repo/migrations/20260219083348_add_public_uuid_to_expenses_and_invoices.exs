defmodule First.Repo.Migrations.AddPublicUuidToExpensesAndInvoices do
  use Ecto.Migration

  def up do
    alter table(:expenses) do
      add :uuid, :binary_id
    end

    alter table(:invoices) do
      add :uuid, :binary_id
    end

    flush()

    execute(fn ->
      backfill_uuid("expenses")
      backfill_uuid("invoices")
    end)

    create unique_index(:expenses, [:uuid])
    create unique_index(:invoices, [:uuid])
  end

  def down do
    drop_if_exists unique_index(:expenses, [:uuid])
    drop_if_exists unique_index(:invoices, [:uuid])

    alter table(:expenses) do
      remove :uuid
    end

    alter table(:invoices) do
      remove :uuid
    end
  end

  defp backfill_uuid(table_name) do
    table_name
    |> all_ids()
    |> Enum.each(fn id ->
      uuid = Ecto.UUID.generate() |> Ecto.UUID.dump!()
      repo().query!("UPDATE #{table_name} SET uuid = $1 WHERE id = $2", [uuid, id])
    end)
  end

  defp all_ids(table_name) do
    %{rows: rows} = repo().query!("SELECT id FROM #{table_name} WHERE uuid IS NULL")
    Enum.map(rows, fn [id] -> id end)
  end
end
