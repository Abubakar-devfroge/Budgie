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

      <%= if Enum.empty?(@invoices_list) do %>
        <div class="flex flex-col items-center justify-center py-20 text-center text-gray-500">
          <img src={~p"/images/table_error.svg"} alt="Empty database" class="h-32 w-32 mb-4 mx-auto" />

          <p class="text-sm font-semibold">
            You haven’t issued any invoices yet. Create one to get started.
          </p>
        </div>
      <% else %>
        <.table
          id="invoices"
          rows={@streams.invoices}
          row_click={fn {_id, invoice} -> JS.navigate(~p"/invoices/#{invoice}") end}
        >
          <:col :let={{_id, invoice}} label="Number">{invoice.invoice_number}</:col>
          <:col :let={{_id, invoice}} label="Status">{invoice.status}</:col>
          <:col :let={{_id, invoice}} label="Amount">KES {invoice.amount}.00</:col>
          <:col :let={{_id, invoice}} label="Client">{invoice.client}</:col>
          <:col :let={{_id, invoice}} label="Issued at">
            {Calendar.strftime(invoice.issued_at, "%b %-d")}
          </:col>
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
      <% end %>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Finance.subscribe_invoices(socket.assigns.current_scope)
    end

    invoices = list_invoices(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Listing Invoices")
     |> assign(:invoices_list, invoices)
     |> stream(:invoices, invoices)}
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
    {:noreply,
     stream(socket, :invoices, list_invoices(socket.assigns.current_scope), reset: true)}
  end

  defp list_invoices(current_scope) do
    Finance.list_invoices(current_scope)
  end
end
