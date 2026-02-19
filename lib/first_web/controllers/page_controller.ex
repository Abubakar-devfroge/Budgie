defmodule FirstWeb.PageController do
  use FirstWeb, :controller
  alias First.Finance
  alias Decimal, as: D

  def home(conn, _params) do
    render(conn, :home)
  end

  def dash(conn, _params) do
    # Assuming you have the current user scope in assigns
    current_scope = conn.assigns[:current_scope]

    # Fetch total invoices
    total_invoices = Finance.total_invoices(current_scope)

    # fetch total expenses
    total_expenses = Finance.total_expenses(current_scope)
    invoices_decimal = to_decimal(total_invoices)
    expenses_decimal = to_decimal(total_expenses)
    net_position = D.sub(invoices_decimal, expenses_decimal)
    cashflow_positive? = D.compare(invoices_decimal, expenses_decimal) in [:gt, :eq]

    # Pass total to template
    render(conn, :dash,
      total_invoices: format_currency(total_invoices),
      total_expenses: format_currency(total_expenses),
      net_position: format_currency(net_position),
      cashflow_positive?: cashflow_positive?
    )
  end

  defp to_decimal(%D{} = value), do: value
  defp to_decimal(value), do: D.new(value)

  defp format_currency(%D{} = value) do
    value
    |> D.round(2)
    |> D.to_string(:normal)
  end

  defp format_currency(value) when is_integer(value), do: "#{value}.00"
  defp format_currency(value) when is_binary(value), do: value
end
