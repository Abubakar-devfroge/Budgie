defmodule First.Finance.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expenses" do
    field :amount, :decimal
    field :price, :decimal
    field :description, :string
    field :category, :string
    field :date, :date
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs, user_scope) do
    expense
    |> cast(attrs, [ :date,:price, :amount, :description, :category,])
    |> validate_required([:amount, :price, :description, :category, :date])
    |> put_change(:user_id, user_scope.user.id)
  end
end
