defmodule FirstWeb.ExpenseLive.Index do
  use FirstWeb, :live_view

  alias First.Finance



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
