defmodule First.Finance.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expenses" do
    field :amount, :decimal
    field :description, :string
    field :category, :string
    field :date, :date
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs, user_scope) do
    expense
    |> cast(attrs, [:amount, :description, :category, :date])
    |> validate_required([:amount, :description, :category, :date])
    |> put_change(:user_id, user_scope.user.id)
  end
end
