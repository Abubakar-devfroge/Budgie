defmodule First.FinanceTest do
  use First.DataCase

  alias First.Finance

  describe "expenses" do
    alias First.Finance.Expense

    import First.AccountsFixtures, only: [user_scope_fixture: 0]
    import First.FinanceFixtures

    @invalid_attrs %{date: nil, description: nil, category: nil, amount: nil}

    test "list_expenses/1 returns all scoped expenses" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      expense = expense_fixture(scope)
      other_expense = expense_fixture(other_scope)
      assert Finance.list_expenses(scope) == [expense]
      assert Finance.list_expenses(other_scope) == [other_expense]
    end

    test "get_expense!/2 returns the expense with given id" do
      scope = user_scope_fixture()
      expense = expense_fixture(scope)
      other_scope = user_scope_fixture()
      assert Finance.get_expense!(scope, expense.id) == expense
      assert_raise Ecto.NoResultsError, fn -> Finance.get_expense!(other_scope, expense.id) end
    end

    test "create_expense/2 with valid data creates a expense" do
      valid_attrs = %{date: ~D[2026-01-04], description: "some description", category: "some category", amount: "120.5"}
      scope = user_scope_fixture()

      assert {:ok, %Expense{} = expense} = Finance.create_expense(scope, valid_attrs)
      assert expense.date == ~D[2026-01-04]
      assert expense.description == "some description"
      assert expense.category == "some category"
      assert expense.amount == Decimal.new("120.5")
      assert expense.user_id == scope.user.id
    end

    test "create_expense/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Finance.create_expense(scope, @invalid_attrs)
    end

    test "update_expense/3 with valid data updates the expense" do
      scope = user_scope_fixture()
      expense = expense_fixture(scope)
      update_attrs = %{date: ~D[2026-01-05], description: "some updated description", category: "some updated category", amount: "456.7"}

      assert {:ok, %Expense{} = expense} = Finance.update_expense(scope, expense, update_attrs)
      assert expense.date == ~D[2026-01-05]
      assert expense.description == "some updated description"
      assert expense.category == "some updated category"
      assert expense.amount == Decimal.new("456.7")
    end

    test "update_expense/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      expense = expense_fixture(scope)

      assert_raise MatchError, fn ->
        Finance.update_expense(other_scope, expense, %{})
      end
    end

    test "update_expense/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      expense = expense_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Finance.update_expense(scope, expense, @invalid_attrs)
      assert expense == Finance.get_expense!(scope, expense.id)
    end

    test "delete_expense/2 deletes the expense" do
      scope = user_scope_fixture()
      expense = expense_fixture(scope)
      assert {:ok, %Expense{}} = Finance.delete_expense(scope, expense)
      assert_raise Ecto.NoResultsError, fn -> Finance.get_expense!(scope, expense.id) end
    end

    test "delete_expense/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      expense = expense_fixture(scope)
      assert_raise MatchError, fn -> Finance.delete_expense(other_scope, expense) end
    end

    test "change_expense/2 returns a expense changeset" do
      scope = user_scope_fixture()
      expense = expense_fixture(scope)
      assert %Ecto.Changeset{} = Finance.change_expense(scope, expense)
    end
  end
end
