defmodule First.Repo.Migrations.CreateExpenses do
  use Ecto.Migration

  def change do
    create table(:expenses) do
      add :amount, :decimal
      add :description, :string
      add :category, :string
      add :date, :date
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:expenses, [:user_id])
  end
end
