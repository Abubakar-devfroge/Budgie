defmodule FirstWeb.ExpenseLiveTest do
  use FirstWeb.ConnCase

  import Phoenix.LiveViewTest
  import First.FinanceFixtures

  @create_attrs %{
    date: "2026-01-04",
    description: "some description",
    category: "some category",
    quantity: "120.5",
    total: "120.5"
  }
  @update_attrs %{
    date: "2026-01-05",
    description: "some updated description",
    category: "some updated category",
    quantity: "456.7",
    total: "456.7"
  }
  @invalid_attrs %{date: nil, description: nil, category: nil, quantity: nil}

  setup :register_and_log_in_user

  defp create_expense(%{scope: scope}) do
    expense = expense_fixture(scope)

    %{expense: expense}
  end

  describe "Index" do
    setup [:create_expense]

    test "lists all expenses", %{conn: conn, expense: expense} do
      {:ok, _index_live, html} = live(conn, ~p"/expenses")

      assert html =~ "Listing Transactions"
      assert html =~ expense.description
    end

    test "saves new expense", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/expenses")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Transaction")
               |> render_click()
               |> follow_redirect(conn, ~p"/expenses/new")

      assert render(form_live) =~ "New Transaction"

      assert form_live
             |> form("#expense-form", expense: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#expense-form", expense: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/expenses")

      html = render(index_live)
      assert html =~ "Transaction created successfully"
      assert html =~ "some description"
    end

    test "updates expense in listing", %{conn: conn, expense: expense} do
      {:ok, index_live, _html} = live(conn, ~p"/expenses")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#expenses-#{expense.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/expenses/#{expense}/edit")

      assert render(form_live) =~ "Edit Transaction"

      assert form_live
             |> form("#expense-form", expense: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#expense-form", expense: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/expenses")

      html = render(index_live)
      assert html =~ "Transaction updated successfully"
      assert html =~ "some updated description"
    end


  end

  describe "Show" do
    setup [:create_expense]

    test "displays expense", %{conn: conn, expense: expense} do
      {:ok, _show_live, html} = live(conn, ~p"/expenses/#{expense}")

      assert html =~ "Show Transaction"
      assert html =~ expense.description
    end

    test "updates expense and returns to show", %{conn: conn, expense: expense} do
      {:ok, show_live, _html} = live(conn, ~p"/expenses/#{expense}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/expenses/#{expense}/edit?return_to=show")

      assert render(form_live) =~ "Edit Transaction"

      assert form_live
             |> form("#expense-form", expense: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#expense-form", expense: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/expenses/#{expense}")

      html = render(show_live)
      assert html =~ "Transaction updated successfully"
      assert html =~ "some updated description"
    end
  end
end
