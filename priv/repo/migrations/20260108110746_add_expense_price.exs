defmodule First.Repo.Migrations.AddExpensePrice do
  use Ecto.Migration

  def change do
    alter table(:expenses) do
      add :price, :decimal, null: false, default: 0.0
    end
  end
end
