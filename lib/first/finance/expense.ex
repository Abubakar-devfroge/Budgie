defmodule First.Finance.Expense do
  @moduledoc """
  Defines the Expense schema and encapsulates business rules related to expenses.
  """
  @derive {Phoenix.Param, key: :uuid}
  use Ecto.Schema
  import Ecto.Changeset

  schema "expenses" do
    field :uuid, Ecto.UUID
    field :quantity, :decimal
    field :total, :decimal
    field :description, :string
    field :date, :date
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs, user_scope) do
    expense
    |> cast(attrs, [:date, :total, :quantity, :description])
    |> validate_length(:description, max: 30)
    |> validate_required([:quantity, :total, :description, :date])
    |> put_uuid()
    |> unique_constraint(:uuid)
    |> put_change(:user_id, user_scope.user.id)
  end

  defp put_uuid(changeset) do
    if get_field(changeset, :uuid) do
      changeset
    else
      put_change(changeset, :uuid, Ecto.UUID.generate())
    end
  end
end
