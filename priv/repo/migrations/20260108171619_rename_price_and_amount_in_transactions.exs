defmodule First.Repo.Migrations.RenamePriceAndAmountInTransactions do
  use Ecto.Migration

  def change do
    rename table(:expenses), :price, to: :total
    rename table(:expenses), :amount, to: :quantity
  end
end
