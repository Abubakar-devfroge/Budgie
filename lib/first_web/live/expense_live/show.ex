defmodule FirstWeb.ExpenseLive.Show do
  use FirstWeb, :live_view

  alias First.Finance

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Transaction {@expense.id}
        <:subtitle>This is a transaction record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/expenses"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/expenses/#{@expense}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Transaction
          </.button>
        </:actions>
      </.header>

      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <.list>
          <:item title="Date">{@expense.date}</:item>
          <:item title="Amount">{@expense.total}</:item>
          <:item title="Price">KES {@expense.quantity}</:item>
          <:item title="Description">{@expense.description}</:item>
          <:item title="Category">{@expense.category}</:item>
        </.list>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Finance.subscribe_expenses(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Transaction")
     |> assign(:expense, Finance.get_expense!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %First.Finance.Expense{id: id} = expense},
        %{assigns: %{expense: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :expense, expense)}
  end

  def handle_info(
        {:deleted, %First.Finance.Expense{id: id}},
        %{assigns: %{expense: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current expense was deleted.")
     |> push_navigate(to: ~p"/expenses")}
  end

  def handle_info({type, %First.Finance.Expense{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
