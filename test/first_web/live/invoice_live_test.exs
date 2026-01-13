defmodule FirstWeb.InvoiceLiveTest do
  use FirstWeb.ConnCase

  import Phoenix.LiveViewTest
  import First.FinanceFixtures

  @create_attrs %{status: "some status", amount: "120.5", invoice_number: "some invoice_number", issued_at: "2026-01-12T20:04:00Z"}
  @update_attrs %{status: "some updated status", amount: "456.7", invoice_number: "some updated invoice_number", issued_at: "2026-01-13T20:04:00Z"}
  @invalid_attrs %{status: nil, amount: nil, invoice_number: nil, issued_at: nil}

  setup :register_and_log_in_user

  defp create_invoice(%{scope: scope}) do
    invoice = invoice_fixture(scope)

    %{invoice: invoice}
  end

  describe "Index" do
    setup [:create_invoice]

    test "lists all invoices", %{conn: conn, invoice: invoice} do
      {:ok, _index_live, html} = live(conn, ~p"/invoices")

      assert html =~ "Listing Invoices"
      assert html =~ invoice.invoice_number
    end

    test "saves new invoice", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/invoices")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Invoice")
               |> render_click()
               |> follow_redirect(conn, ~p"/invoices/new")

      assert render(form_live) =~ "New Invoice"

      assert form_live
             |> form("#invoice-form", invoice: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#invoice-form", invoice: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/invoices")

      html = render(index_live)
      assert html =~ "Invoice created successfully"
      assert html =~ "some invoice_number"
    end

    test "updates invoice in listing", %{conn: conn, invoice: invoice} do
      {:ok, index_live, _html} = live(conn, ~p"/invoices")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#invoices-#{invoice.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/invoices/#{invoice}/edit")

      assert render(form_live) =~ "Edit Invoice"

      assert form_live
             |> form("#invoice-form", invoice: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#invoice-form", invoice: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/invoices")

      html = render(index_live)
      assert html =~ "Invoice updated successfully"
      assert html =~ "some updated invoice_number"
    end

    test "deletes invoice in listing", %{conn: conn, invoice: invoice} do
      {:ok, index_live, _html} = live(conn, ~p"/invoices")

      assert index_live |> element("#invoices-#{invoice.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#invoices-#{invoice.id}")
    end
  end

  describe "Show" do
    setup [:create_invoice]

    test "displays invoice", %{conn: conn, invoice: invoice} do
      {:ok, _show_live, html} = live(conn, ~p"/invoices/#{invoice}")

      assert html =~ "Show Invoice"
      assert html =~ invoice.invoice_number
    end

    test "updates invoice and returns to show", %{conn: conn, invoice: invoice} do
      {:ok, show_live, _html} = live(conn, ~p"/invoices/#{invoice}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/invoices/#{invoice}/edit?return_to=show")

      assert render(form_live) =~ "Edit Invoice"

      assert form_live
             |> form("#invoice-form", invoice: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#invoice-form", invoice: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/invoices/#{invoice}")

      html = render(show_live)
      assert html =~ "Invoice updated successfully"
      assert html =~ "some updated invoice_number"
    end
  end
end
