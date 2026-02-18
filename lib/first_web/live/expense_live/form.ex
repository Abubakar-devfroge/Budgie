defmodule FirstWeb.ExpenseLive.Form do
  use FirstWeb, :live_view

  alias First.Finance
  alias First.Finance.Expense

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <%!-- <:subtitle>
          Use this form to track and manage your company’s transactions efficiently.
        </:subtitle> --%>
      </.header>

      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <.form
          for={@form}
          id="expense-form"
          phx-change="validate"
          phx-submit="save"
          phx-hook="LocalTimeMeta"
        >
          <input type="hidden" name="expense[tz_offset_minutes]" />
          <.input field={@form[:total]} type="number" label="Total Price" step="any" />
          <.input field={@form[:quantity]} type="number" label="Quantity" step="any" />
          <.input field={@form[:description]} type="text" label="Description" />
          <.input field={@form[:category]} type="text" label="Category" />

          <footer>
            <.button phx-disable-with="Saving..." variant="primary">Save Expense</.button>
            <.button navigate={return_path(@current_scope, @return_to, @expense)}>Cancel</.button>
          </footer>
        </.form>
      </div>
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

  defp apply_action(socket, :edit, %{"id" => id}) do
    expense = Finance.get_expense!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Expense")
    |> assign(:expense, expense)
    |> assign(:form, to_form(Finance.change_expense(socket.assigns.current_scope, expense)))
  end

  defp apply_action(socket, :new, _params) do
    expense = %Expense{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Expense")
    |> assign(:expense, expense)
    |> assign(:form, to_form(Finance.change_expense(socket.assigns.current_scope, expense)))
  end

  @impl true
  def handle_event("validate", %{"expense" => expense_params}, socket) do
    expense_params = maybe_put_date(expense_params)

    changeset =
      Finance.change_expense(socket.assigns.current_scope, socket.assigns.expense, expense_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"expense" => expense_params}, socket) do
    expense_params = maybe_put_date(expense_params)
    save_expense(socket, socket.assigns.live_action, expense_params)
  end

  defp maybe_put_date(params) do
    case Map.get(params, "date") do
      nil -> Map.put(params, "date", local_today_iso8601(params))
      "" -> Map.put(params, "date", local_today_iso8601(params))
      _ -> params
    end
  end

  defp local_today_iso8601(params) do
    offset_minutes =
      case Integer.parse(Map.get(params, "tz_offset_minutes", "0")) do
        {value, _} -> value
        :error -> 0
      end

    DateTime.utc_now()
    |> DateTime.add(-offset_minutes * 60, :second)
    |> DateTime.to_date()
    |> Date.to_iso8601()
  end

  defp save_expense(socket, :edit, expense_params) do
    case Finance.update_expense(
           socket.assigns.current_scope,
           socket.assigns.expense,
           expense_params
         ) do
      {:ok, expense} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, expense)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_expense(socket, :new, expense_params) do
    case Finance.create_expense(socket.assigns.current_scope, expense_params) do
      {:ok, expense} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, expense)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _expense), do: ~p"/expenses"

  defp return_path(_scope, "show", expense), do: ~p"/expenses/#{expense}"
end
