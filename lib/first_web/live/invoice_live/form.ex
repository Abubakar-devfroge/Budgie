defmodule FirstWeb.InvoiceLive.Form do
  use FirstWeb, :live_view

  alias First.Finance
  alias First.Finance.Invoice

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage invoice records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="invoice-form" phx-change="validate" phx-submit="save">
        <!-- Display invoice number as read-only since it's auto-generated -->
        <.input field={@form[:invoice_number]} type="text" label="Invoice number" readonly />

        <.input field={@form[:amount]} type="number" label="Amount" step="any" />

        <.input field={@form[:status]} type="select" label="Status" options={["not paid", "paid"]} />

        <.input field={@form[:issued_at]} type="datetime-local" label="Issued at" />

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Invoice</.button>
          <.button navigate={return_path(@current_scope, @return_to, @invoice)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  # EDIT
  defp apply_action(socket, :edit, %{"id" => id}) do
    invoice = Finance.get_invoice!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Invoice")
    |> assign(:invoice, invoice)
    |> assign(:form, to_form(Finance.change_invoice(socket.assigns.current_scope, invoice)))
  end

  # NEW
  defp apply_action(socket, :new, _params) do
    # remove any user_id reference
    invoice = %Invoice{}

    socket
    |> assign(:page_title, "New Invoice")
    |> assign(:invoice, invoice)
    |> assign(:form, to_form(Finance.change_invoice(socket.assigns.current_scope, invoice)))
  end

  @impl true
  def handle_event("validate", %{"invoice" => invoice_params}, socket) do
    changeset =
      Finance.change_invoice(socket.assigns.current_scope, socket.assigns.invoice, invoice_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"invoice" => invoice_params}, socket) do
    save_invoice(socket, socket.assigns.live_action, invoice_params)
  end

  defp save_invoice(socket, :edit, invoice_params) do
    case Finance.update_invoice(
           socket.assigns.current_scope,
           socket.assigns.invoice,
           invoice_params
         ) do
      {:ok, invoice} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invoice updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, invoice)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_invoice(socket, :new, invoice_params) do
    case Finance.create_invoice(socket.assigns.current_scope, invoice_params) do
      {:ok, invoice} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invoice created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, invoice)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _invoice), do: ~p"/invoices"
  defp return_path(_scope, "show", invoice), do: ~p"/invoices/#{invoice}"
end
