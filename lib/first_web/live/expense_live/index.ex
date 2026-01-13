defmodule FirstWeb.ExpenseLive.Index do
  use FirstWeb, :live_view

  alias First.Finance
  alias FirstWeb.ExpenseComponents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        <h3 class="  text-xl font-bold text-gray-900">Home</h3>
        <:actions>
          <.button variant="primary" navigate={~p"/expenses/new"}>
            <.icon name="hero-plus" /> New Transaction
          </.button>
        </:actions>
      </.header>

      <ExpenseComponents.dashboard_cards current_scope={@current_scope} />

      <div class="flex-shrink mb-4">
        <h2 class="uppercase text-sm font-medium text-gray-600 tracking-wide">
          Quick Access
        </h2>
      </div>

      <%= if Enum.empty?(@expenses_list) do %>
        <div class="flex flex-col items-center justify-center py-20 text-center text-gray-500">
          <img src={~p"/images/table_error.svg"} alt="Empty database" class="h-32 w-32 mb-4 mx-auto" />

          <p class="text-sm font-semibold">Your ledger is empty. Start by adding a transaction.</p>
        </div>
      <% else %>
        <.table
          id="expenses"
          rows={@streams.expenses}
          row_click={fn {_id, expense} -> JS.navigate(~p"/expenses/#{expense}") end}
        >
          <:col :let={{_id, expense}} label="Date">{expense.date}</:col>
          <:col :let={{_id, expense}} label="Total">KES {expense.total}</:col>
          <:col :let={{_id, expense}} label="Description">{expense.description}</:col>
          <:col :let={{_id, expense}} label="Category">{expense.category}</:col>

          <:action :let={{_id, expense}}>
            <div class="sr-only">
              <.link navigate={~p"/expenses/#{expense}"}>Show</.link>
            </div>
            <.link navigate={~p"/expenses/#{expense}/edit"}>Edit</.link>
          </:action>
          <:action :let={{id, expense}}>
            <.link
              phx-click={JS.push("delete", value: %{id: expense.id}) |> hide("##{id}")}
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
      Finance.subscribe_expenses(socket.assigns.current_scope)
    end

    expenses = list_expenses(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Listing Transactions")
     |> assign(:expenses_list, expenses)
     |> stream(:expenses, expenses)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    expense = Finance.get_expense!(socket.assigns.current_scope, id)
    {:ok, _} = Finance.delete_expense(socket.assigns.current_scope, expense)

    new_expenses_list = Enum.reject(socket.assigns.expenses_list, fn e -> e.id == expense.id end)

    {:noreply,
     socket
     |> assign(:expenses_list, new_expenses_list)
     |> stream_delete(:expenses, expense)}
  end

  @impl true
  def handle_info({type, %First.Finance.Expense{}}, socket)
      when type in [:created, :updated, :deleted] do
    expenses = list_expenses(socket.assigns.current_scope)

    {:noreply,
     socket
     |> assign(:expenses_list, expenses)
     |> stream(:expenses, expenses, reset: true)}
  end

  defp list_expenses(current_scope) do
    Finance.list_expenses(current_scope)
  end
end
