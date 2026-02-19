defmodule First.Finance.Invoice do
  @moduledoc """
  Defines the Invoice schema and encapsulates business rules related to invoicing.
  """

  @derive {Phoenix.Param, key: :uuid}
  use Ecto.Schema
  import Ecto.Changeset

  schema "invoices" do
    field :uuid, Ecto.UUID
    field :invoice_number, :string
    field :client, :string
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
    |> cast(attrs, [:client, :amount, :status, :issued_at])
    |> validate_required([:client, :amount, :status, :issued_at])
    |> validate_length(:client, max: 20)
    |> put_change(:user_id, user_id)
    |> put_uuid()
    |> unique_constraint(:uuid)
    |> put_invoice_number()
  end

  # random invoice number generation
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

  defp put_uuid(changeset) do
    if get_field(changeset, :uuid) do
      changeset
    else
      put_change(changeset, :uuid, Ecto.UUID.generate())
    end
  end
end
