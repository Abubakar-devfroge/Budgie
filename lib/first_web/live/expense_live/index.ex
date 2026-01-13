defmodule FirstWeb.ExpenseLive.Index do
  use FirstWeb, :live_view

  alias First.Finance

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        <:actions>
          <.button variant="primary" navigate={~p"/expenses/new"}>
            <.icon name="hero-plus" /> New Transaction
          </.button>
        </:actions>
      </.header>

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
          <:col :let={{_id, expense}} label="Type">
            <span class="inline-flex items-center rounded-full bg-red-700 px-3 py-1 text-xs font-medium text-white ring-1 ring-inset ring-red-600/10">
              {expense.category}
            </span>
          </:col>

          <:action :let={{id, expense}}>
            <el-dropdown class="inline-block">
              <button
                type="button"
                class="inline-flex items-center gap-x-1.5 r px-3 py-2 text-sm font-semibold text-gray-900 "
              >
                ...
              </button>

              <el-menu
                anchor="bottom end"
                popover
                class="w-44 origin-top-right rounded-md bg-white shadow-lg outline outline-1 outline-black/5"
              >
                <div class="py-1">
                  <!-- Show -->
                  <.link
                    navigate={~p"/expenses/#{expense}"}
                    class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                  >
                    Show
                  </.link>
                  
    <!-- Edit -->
                  <.link
                    navigate={~p"/expenses/#{expense}/edit"}
                    class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                  >
                    Edit
                  </.link>
                  
    <!-- Delete (LOGIC UNCHANGED) -->
                  <button
                    type="button"
                    phx-click={JS.push("delete", value: %{id: expense.id}) |> hide("##{id}")}
                    data-confirm="Are you sure?"
                    class="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50"
                  >
                    Delete
                  </button>
                </div>
              </el-menu>
            </el-dropdown>
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
