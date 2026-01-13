defmodule First.FinanceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `First.Finance` context.
  """

  @doc """
  Generate a expense.
  """
  def expense_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        total: "120.5",
        quantity: "120.5",
        category: "some category",
        date: ~D[2026-01-04],
        description: "some description"
      })

    {:ok, expense} = First.Finance.create_expense(scope, attrs)
    expense
  end

  @doc """
  Generate a invoice.
  """
  def invoice_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        amount: "120.5",
        invoice_number: "some invoice_number",
        issued_at: ~U[2026-01-12 20:04:00Z],
        status: "some status"
      })

    {:ok, invoice} = First.Finance.create_invoice(scope, attrs)
    invoice
  end
end
