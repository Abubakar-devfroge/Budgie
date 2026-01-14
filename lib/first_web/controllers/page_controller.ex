defmodule FirstWeb.PageController do
  use FirstWeb, :controller
  alias First.Finance

  def home(conn, _params) do
    render(conn, :home)
  end

  def dash(conn, _params) do
    # Assuming you have the current user scope in assigns
    current_scope = conn.assigns[:current_scope]

    # Fetch total invoices
    total_invoices = Finance.total_invoices(current_scope)

    # Pass total to template
    render(conn, :dash, total_invoices: total_invoices)
  end
end
