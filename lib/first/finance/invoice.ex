defmodule First.Finance.Invoice do
  @moduledoc """
  Defines the Invoice schema and encapsulates business rules related to invoicing.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "invoices" do
    field :invoice_number, :string
    field :amount, :decimal
    field :status, :string, default: "not paid"
    field :issued_at, :utc_datetime

    belongs_to :user, First.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs, scope) do
    user_id =
      case scope do
        %{user: user} -> user.id
        _ -> nil
      end

    invoice
    |> cast(attrs, [:amount, :status, :issued_at])
    |> validate_required([:amount, :status, :issued_at])
    # automatically set user_id from scope if available
    |> put_change(:user_id, user_id)
    |> put_invoice_number()
  end

  # Automatically generates a random invoice number
  defp put_invoice_number(changeset) do
    if get_field(changeset, :invoice_number) do
      changeset
    else
      put_change(changeset, :invoice_number, random_invoice_number())
    end
  end

  defp random_invoice_number do
    chars = Enum.to_list(?A..?Z) ++ Enum.to_list(?0..?9)

    Enum.map(1..7, fn _ -> Enum.random(chars) end)
    |> to_string()
  end
end
