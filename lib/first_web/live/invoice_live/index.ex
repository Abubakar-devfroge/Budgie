defmodule FirstWeb.InvoiceLive.Index do
  use FirstWeb, :live_view

  alias First.Finance

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Invoices
        <:actions>
          <.button variant="primary" navigate={~p"/invoices/new"}>
            <.icon name="hero-plus" /> New Invoice
          </.button>
        </:actions>
      </.header>

      <.table
        id="invoices"
        rows={@streams.invoices}
        row_click={fn {_id, invoice} -> JS.navigate(~p"/invoices/#{invoice}") end}
      >
        <:col :let={{_id, invoice}} label="Invoice number">{invoice.invoice_number}</:col>
        <:col :let={{_id, invoice}} label="Amount">{invoice.amount}</:col>
        <:col :let={{_id, invoice}} label="Status">{invoice.status}</:col>
        <:col :let={{_id, invoice}} label="Issued at">{invoice.issued_at}</:col>
        <:action :let={{_id, invoice}}>
          <div class="sr-only">
            <.link navigate={~p"/invoices/#{invoice}"}>Show</.link>
          </div>
          <.link navigate={~p"/invoices/#{invoice}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, invoice}}>
          <.link
            phx-click={JS.push("delete", value: %{id: invoice.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Finance.subscribe_invoices(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Invoices")
     |> stream(:invoices, list_invoices(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    invoice = Finance.get_invoice!(socket.assigns.current_scope, id)
    {:ok, _} = Finance.delete_invoice(socket.assigns.current_scope, invoice)

    {:noreply, stream_delete(socket, :invoices, invoice)}
  end

  @impl true
  def handle_info({type, %First.Finance.Invoice{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :invoices, list_invoices(socket.assigns.current_scope), reset: true)}
  end

  defp list_invoices(current_scope) do
    Finance.list_invoices(current_scope)
  end
end
