defmodule FirstWeb.ExpenseLive.Index do
  use FirstWeb, :live_view

  alias First.Finance

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Finance.subscribe_expenses(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> stream_configure(:expenses, dom_id: &"expenses-#{&1.uuid}")
     |> assign(:page_title, "Listing Transactions")
     |> assign(:search_query, "")
     |> refresh_expenses()}
  end

  @impl true
  def handle_event("search", %{"search" => %{"q" => query}}, socket) do
    {:noreply,
     socket
     |> assign(:search_query, query)
     |> refresh_expenses()}
  end

  @impl true
  def handle_event("delete", %{"uuid" => uuid}, socket) do
    expense = Finance.get_expense!(socket.assigns.current_scope, uuid)
    {:ok, _} = Finance.delete_expense(socket.assigns.current_scope, expense)

    {:noreply, refresh_expenses(socket)}
  end

  @impl true
  def handle_info({type, %First.Finance.Expense{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, refresh_expenses(socket)}
  end

  defp list_expenses(current_scope) do
    Finance.list_expenses(current_scope)
  end

  defp refresh_expenses(socket) do
    expenses = list_expenses(socket.assigns.current_scope)
    filtered_expenses = filter_expenses(expenses, socket.assigns.search_query)

    socket
    |> assign(:expenses_list, expenses)
    |> assign(:expenses_count, length(expenses))
    |> assign(:filtered_expenses_count, length(filtered_expenses))
    |> stream(:expenses, filtered_expenses, reset: true)
  end

  defp filter_expenses(expenses, query) do
    normalized_query = normalize(query)

    if normalized_query == "" do
      expenses
    else
      Enum.filter(expenses, fn expense ->
        expense
        |> expense_search_fields()
        |> Enum.any?(fn field ->
          field
          |> normalize()
          |> String.contains?(normalized_query)
        end)
      end)
    end
  end

  defp expense_search_fields(expense) do
    [
      if(expense.date, do: Date.to_iso8601(expense.date), else: ""),
      expense.description,
      expense.category,
      to_string(expense.quantity),
      to_string(expense.total)
    ]
  end

  defp normalize(nil), do: ""
  defp normalize(value), do: value |> to_string() |> String.downcase() |> String.trim()
end
