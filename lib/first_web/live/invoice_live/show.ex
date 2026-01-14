defmodule FirstWeb.InvoiceLive.Show do
  use FirstWeb, :live_view

  alias First.Finance

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Invoice {@invoice.id}
        <:subtitle>This is a invoice record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/invoices"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/invoices/#{@invoice}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit invoice
          </.button>
        </:actions>
      </.header>

      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <.list>
          <:item title="Invoice number">{@invoice.invoice_number}</:item>
          <:item title="Amount">{@invoice.amount}</:item>
          <:item title="Status">{@invoice.status}</:item>
          <:item title="Issued at">{@invoice.issued_at}</:item>
        </.list>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Finance.subscribe_invoices(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Invoice")
     |> assign(:invoice, Finance.get_invoice!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %First.Finance.Invoice{id: id} = invoice},
        %{assigns: %{invoice: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :invoice, invoice)}
  end

  def handle_info(
        {:deleted, %First.Finance.Invoice{id: id}},
        %{assigns: %{invoice: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current invoice was deleted.")
     |> push_navigate(to: ~p"/invoices")}
  end

  def handle_info({type, %First.Finance.Invoice{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
