defmodule FirstWeb.ExpenseLive.Index do
  use FirstWeb, :live_view

  alias First.Finance

  @impl true
  def render(assigns) do
    ~H"""


    <Layouts.app flash={@flash} current_scope={@current_scope}>

        <li class="text-sm text-gray-600 font-medium">
          {@current_scope.user.email}
        </li>

      <.header>
          <%!-- <p>Total Expenses: <%= Enum.count(@streams.expenses) %></p> --%>
        <:actions>
          <.button variant="primary" navigate={~p"/expenses/new"}>
            <.icon name="hero-plus" /> New Transaction
          </.button>

        </:actions>
      </.header>

      <.table
        id="expenses"
        rows={@streams.expenses}
        row_click={fn {_id, expense} -> JS.navigate(~p"/expenses/#{expense}") end}
      >
       <:col :let={{_id, expense}} label="Date">{expense.date}</:col>
        <:col :let={{_id, expense}} label="Price">{expense.price}</:col>
        <:col :let={{_id, expense}} label="Amount">{expense.amount}</:col>
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
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Finance.subscribe_expenses(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Transactions")
     |> stream(:expenses, list_expenses(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    expense = Finance.get_expense!(socket.assigns.current_scope, id)
    {:ok, _} = Finance.delete_expense(socket.assigns.current_scope, expense)

    {:noreply, stream_delete(socket, :expenses, expense)}
  end

  @impl true
  def handle_info({type, %First.Finance.Expense{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :expenses, list_expenses(socket.assigns.current_scope), reset: true)}
  end

  defp list_expenses(current_scope) do
    Finance.list_expenses(current_scope)
  end
end
