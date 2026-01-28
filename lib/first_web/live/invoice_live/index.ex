defmodule FirstWeb.InvoiceLive.Index do
  use FirstWeb, :live_view

  alias First.Finance

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
