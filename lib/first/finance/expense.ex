defmodule First.Finance.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expenses" do
    field :quantity, :decimal
    field :total, :decimal
    field :description, :string
    field :category, :string
    field :date, :date
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs, user_scope) do
    expense
    |> cast(attrs, [ :date,:total, :quantity, :description, :category,])
    |> validate_required([:quantity, :total, :description, :category, :date])
    |> put_change(:user_id, user_scope.user.id)
  end
end
