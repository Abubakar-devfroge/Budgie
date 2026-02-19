defmodule FirstWeb.InvoiceLive.Index do
  use FirstWeb, :live_view

  alias First.Finance

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Finance.subscribe_invoices(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> stream_configure(:invoices, dom_id: &"invoices-#{&1.uuid}")
     |> assign(:page_title, "Listing Invoices")
     |> assign(:search_query, "")
     |> refresh_invoices()}
  end

  @impl true
  def handle_event("search", %{"search" => %{"q" => query}}, socket) do
    {:noreply,
     socket
     |> assign(:search_query, query)
     |> refresh_invoices()}
  end

  @impl true
  def handle_event("delete", %{"uuid" => uuid}, socket) do
    invoice = Finance.get_invoice!(socket.assigns.current_scope, uuid)
    {:ok, _} = Finance.delete_invoice(socket.assigns.current_scope, invoice)

    {:noreply, refresh_invoices(socket)}
  end

  @impl true
  def handle_info({type, %First.Finance.Invoice{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, refresh_invoices(socket)}
  end

  defp list_invoices(current_scope) do
    Finance.list_invoices(current_scope)
  end

  defp refresh_invoices(socket) do
    invoices = list_invoices(socket.assigns.current_scope)
    filtered_invoices = filter_invoices(invoices, socket.assigns.search_query)

    socket
    |> assign(:invoices_list, invoices)
    |> assign(:invoices_count, length(invoices))
    |> assign(:filtered_invoices_count, length(filtered_invoices))
    |> stream(:invoices, filtered_invoices, reset: true)
  end

  defp filter_invoices(invoices, query) do
    normalized_query = normalize(query)

    if normalized_query == "" do
      invoices
    else
      Enum.filter(invoices, fn invoice ->
        invoice
        |> invoice_search_fields()
        |> Enum.any?(fn field ->
          field
          |> normalize()
          |> String.contains?(normalized_query)
        end)
      end)
    end
  end

  defp invoice_search_fields(invoice) do
    [
      invoice.invoice_number,
      invoice.client,
      invoice.status,
      to_string(invoice.amount),
      if(invoice.issued_at, do: DateTime.to_iso8601(invoice.issued_at), else: "")
    ]
  end

  defp normalize(nil), do: ""
  defp normalize(value), do: value |> to_string() |> String.downcase() |> String.trim()
end
