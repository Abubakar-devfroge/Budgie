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
        amount: "120.5",
        price: "120.5",
        category: "some category",
        date: ~D[2026-01-04],
        description: "some description"
      })

    {:ok, expense} = First.Finance.create_expense(scope, attrs)
    expense
  end
end
