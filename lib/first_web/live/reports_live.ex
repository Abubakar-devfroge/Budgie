defmodule FirstWeb.ReportsLive do
  use FirstWeb, :live_view

  alias First.Finance

  @tabs ["spending", "income", "net_income", "summary"]

  @impl true
  def mount(_params, _session, socket) do
    total_expenses = Finance.total_expenses(socket.assigns.current_scope)
    total_invoices = Finance.total_invoices(socket.assigns.current_scope)
    expenses = Finance.list_expenses(socket.assigns.current_scope)
    invoices = Finance.list_invoices(socket.assigns.current_scope)
    net_income_rows = build_net_income_rows(expenses, invoices)

    {:ok,
     socket
     |> assign(:page_title, "Reports")
     |> assign(:active_tab, "spending")
     |> assign(:total_expenses, total_expenses)
     |> assign(:total_invoices, total_invoices)
     |> assign(:net_income_total, Decimal.sub(total_invoices, total_expenses))
     |> assign(:expenses, expenses)
     |> assign(:invoices, invoices)
     |> assign(:net_income_rows, net_income_rows)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    tab =
      case params["tab"] do
        value when value in @tabs -> value
        _ -> "spending"
      end

    {:noreply, assign(socket, :active_tab, tab)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex gap-5 overflow-x-auto pb-1  ">
        <div class="min-w-64 flex-1 overflow-hidden rounded-lg bg-white px-4 py-5  border border-gray-200 sm:p-6">
          <dt class="truncate text-sm font-medium text-gray-500">Total Invoices</dt>
          <dd class="mt-1 text-lg font-semibold tracking-tight text-gray-900">
            {format_amount(@total_invoices)}
          </dd>
        </div>

        <div class="min-w-64 flex-1 overflow-hidden rounded-lg bg-white px-4 py-5  border border-gray-200 sm:p-6">
          <dt class="truncate text-sm font-medium text-gray-500">Total Expenses</dt>
          <dd class="mt-1 text-lg font-semibold tracking-tight text-amber-800">
            {format_amount(@total_expenses)}
          </dd>
        </div>

        <div class="min-w-64 flex-1 overflow-hidden rounded-lg bg-white px-4 py-5  border border-gray-200 sm:p-6">
          <dt class="truncate text-sm font-medium text-gray-500">Net Income</dt>
          <dd class="mt-1 text-lg font-semibold tracking-tight text-green-400">
            {format_amount(@net_income_total)}
          </dd>
        </div>
      </div>

      <div class="mt-4 grid grid-cols-1 gap-4 lg:grid-cols-[16rem_minmax(0,1fr)]">
        <aside class="h-fit rounded-md border border-gray-200 bg-white ">
          <div class="border-b border-gray-100 px-4 py-3">
            <p class="text-xs font-semibold uppercase tracking-wide text-gray-700">ANALYTICS</p>
            <p class="mt-1 text-sm text-gray-500">Report Settings</p>
          </div>

          <nav role="tablist" aria-label="Reports menu" class="p-2">
            <.link
              patch={~p"/reports?tab=spending"}
              role="tab"
              aria-selected={@active_tab == "spending"}
              class={[
                "mb-1 flex items-center rounded-md px-3 py-2 text-sm font-medium transition",
                @active_tab == "spending" && "bg-red-50 text-red-700 ",
                @active_tab != "spending" && "text-gray-700 hover:bg-gray-50"
              ]}
            >
              Spending
            </.link>

            <.link
              patch={~p"/reports?tab=income"}
              role="tab"
              aria-selected={@active_tab == "income"}
              class={[
                "mb-1 flex items-center rounded-md px-3 py-2 text-sm font-medium transition",
                @active_tab == "income" && "bg-red-50 text-red-700 ",
                @active_tab != "income" && "text-gray-700 hover:bg-gray-50"
              ]}
            >
              Income
            </.link>

            <.link
              patch={~p"/reports?tab=net_income"}
              role="tab"
              aria-selected={@active_tab == "net_income"}
              class={[
                "mb-1 flex items-center rounded-md px-3 py-2 text-sm font-medium transition",
                @active_tab == "net_income" && "bg-red-50 text-red-700 ",
                @active_tab != "net_income" && "text-gray-700 hover:bg-gray-50"
              ]}
            >
              Net Income
            </.link>

            <.link
              patch={~p"/reports?tab=summary"}
              role="tab"
              aria-selected={@active_tab == "summary"}
              class={[
                "flex items-center rounded-md px-3 py-2 text-sm font-medium transition",
                @active_tab == "summary" && "bg-red-50 text-red-700 ",
                @active_tab != "summary" && "text-gray-700 hover:bg-gray-50"
              ]}
            >
              Summary
            </.link>
          </nav>
        </aside>

        <div role="tabpanel">
        <%= cond do %>
          <% @active_tab == "spending" -> %>
          <div class="border border-gray-200 bg-white rounded-md">
            <%= if @expenses == [] do %>
              <.no_records_state />
            <% else %>
              <div class="flex items-center justify-end border-b border-gray-100 px-4 py-3 sm:px-6">
                <button
                  command="show-modal"
                  commandfor="export-expenses-dialog"
                  class="inline-flex items-center gap-1.5 rounded-md bg-black px-2.5 py-1.5 text-sm font-semibold text-white hover:bg-gray-900"
                >
                  <.icon name="hero-arrow-down-tray" class="size-4" />
                  Export
                </button>
              </div>

              <.export_modal dialog_id="export-expenses-dialog" dataset="expenses" title="Export Expenses" />

              <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200 text-sm">
                  <thead class="bg-gray-50 text-gray-700">
                    <tr>
                      <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide sm:px-6">
                        Date
                      </th>
                      <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide sm:px-6">
                        Expense
                      </th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-gray-200 bg-white text-gray-900">
                    <tr :for={expense <- @expenses} class="hover:bg-gray-50 transition-colors">
                      <td class="px-4 py-3 font-medium sm:px-6">
                        {Calendar.strftime(expense.date, "%b %-d")}
                      </td>
                      <td class="px-4 py-3 whitespace-nowrap sm:px-6 text-amber-800">KES {expense.total}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            <% end %>
          </div>

          <% @active_tab == "income" -> %>
            <div class="border border-gray-200 bg-white rounded-md">
              <%= if @invoices == [] do %>
                <.no_records_state />
              <% else %>
                <div class="flex items-center justify-end border-b border-gray-100 px-4 py-3 sm:px-6">
                  <button
                    command="show-modal"
                    commandfor="export-invoices-dialog"
                    class="inline-flex items-center gap-1.5 rounded-md bg-black px-2.5 py-1.5 text-sm font-semibold text-white hover:bg-gray-900"
                  >
                    <.icon name="hero-arrow-down-tray" class="size-4" />
                    Export
                  </button>
                </div>

                <.export_modal dialog_id="export-invoices-dialog" dataset="invoices" title="Export Income" />

                <div class="overflow-x-auto">
                  <table class="min-w-full divide-y divide-gray-200 text-sm">
                    <thead class="bg-gray-50 text-gray-700">
                      <tr>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide sm:px-6">
                          Date
                        </th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide sm:px-6">
                          Invoice
                        </th>
                      </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 bg-white text-gray-900">
                      <tr :for={invoice <- @invoices} class="hover:bg-gray-50 transition-colors">
                        <td class="px-4 py-3 font-medium sm:px-6">
                          {format_invoice_date(invoice.issued_at)}
                        </td>
                        <td class="px-4 py-3 whitespace-nowrap sm:px-6 text-green-400">KES {invoice.amount}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              <% end %>
            </div>

          <% @active_tab == "net_income" -> %>
            <div class="border border-gray-200 bg-white rounded-md">
              <%= if @net_income_rows == [] do %>
                <.no_records_state />
              <% else %>
                <div class="flex items-center justify-end border-b border-gray-100 px-4 py-3 sm:px-6">
                  <button
                    command="show-modal"
                    commandfor="export-net-income-dialog"
                    class="inline-flex items-center gap-1.5 rounded-md bg-black px-2.5 py-1.5 text-sm font-semibold text-white hover:bg-gray-900"
                  >
                    <.icon name="hero-arrow-down-tray" class="size-4" />
                    Export
                  </button>
                </div>

                <.export_modal dialog_id="export-net-income-dialog" dataset="net_income" title="Export Net Income" />

                <div class="overflow-x-auto">
                  <table class="min-w-full divide-y divide-gray-200 text-sm">
                    <thead class="bg-gray-50 text-gray-700">
                      <tr>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide sm:px-6">
                          Date
                        </th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide sm:px-6">
                          Net Income
                        </th>
                      </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 bg-white text-gray-900">
                      <tr :for={row <- @net_income_rows} class="hover:bg-gray-50 transition-colors">
                        <td class="px-4 py-3 font-medium sm:px-6">
                          {Calendar.strftime(row.date, "%b %-d")}
                        </td>
                        <td class="px-4 py-3 whitespace-nowrap sm:px-6 text-green-400">
                          KES {format_amount(row.net_income)}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              <% end %>
            </div>

          <% true -> %>
            <div class="block rounded-md border border-gray-300 p-4 shadow-sm sm:p-6">
              <div class="sm:flex sm:justify-between sm:gap-4 lg:gap-6">
                <div class="sm:order-last sm:w-72 sm:shrink-0">
                  <div class="rounded-md border border-gray-200 bg-gray-50 p-3">
                    <div class="mb-2 flex items-center justify-between">
                      <p class="text-xs font-semibold uppercase tracking-wide text-gray-500">
                        Report Chart
                      </p>
                      <span class="text-xs text-amber-800">Live</span>
                    </div>

                    <div class="space-y-2">
                      <div :for={bar <- chart_bars(@active_tab)} class="space-y-1">
                        <div class="flex items-center justify-between">
                          <span class="text-xs text-gray-600">{bar.label}</span>
                          <span class="text-xs font-medium text-gray-700">{bar.value}</span>
                        </div>

                        <div class="h-2 rounded-full bg-gray-200">
                          <div class={["h-2 rounded-full", bar.color_class, bar.width_class]}></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="mt-4 sm:mt-0">
                  <h3 class="text-lg font-medium text-pretty text-gray-900">{card_title(@active_tab)}</h3>

                  <p class="mt-1 text-sm text-gray-700">{card_subtitle(@active_tab)}</p>

                  <p class="mt-4 line-clamp-2 text-sm text-pretty text-gray-700">
                    {card_description(@active_tab, @total_expenses, @total_invoices)}
                  </p>
                </div>
              </div>

              <dl class="mt-6 flex gap-4 lg:gap-6">
                <div class="flex items-center gap-2">
                  <dt class="text-gray-700">
                    <span class="sr-only">Published on</span>
                    <.icon name="hero-calendar-days" class="size-5" />
                  </dt>

                  <dd class="text-xs text-gray-700">{Date.utc_today() |> Date.to_string()}</dd>
                </div>

                <div class="flex items-center gap-2">
                  <dt class="text-gray-700">
                    <span class="sr-only">Reading time</span>
                    <.icon name="hero-book-open" class="size-5" />
                  </dt>

                  <dd class="text-xs text-gray-700">Report</dd>
                </div>
              </dl>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp build_net_income_rows(expenses, invoices) do
    invoice_totals_by_date =
      Enum.reduce(invoices, %{}, fn invoice, acc ->
        case invoice.issued_at do
          %DateTime{} = issued_at ->
            date = DateTime.to_date(issued_at)
            amount = decimal_or_zero(invoice.amount)
            Map.update(acc, date, amount, &Decimal.add(&1, amount))

          _ ->
            acc
        end
      end)

    expense_totals_by_date =
      Enum.reduce(expenses, %{}, fn expense, acc ->
        case expense.date do
          %Date{} = date ->
            amount = decimal_or_zero(expense.total)
            Map.update(acc, date, amount, &Decimal.add(&1, amount))

          _ ->
            acc
        end
      end)

    invoice_totals_by_date
    |> Map.keys()
    |> Kernel.++(Map.keys(expense_totals_by_date))
    |> Enum.uniq()
    |> Enum.sort(&(Date.compare(&1, &2) in [:gt, :eq]))
    |> Enum.map(fn date ->
      invoice_total = Map.get(invoice_totals_by_date, date, Decimal.new(0))
      expense_total = Map.get(expense_totals_by_date, date, Decimal.new(0))

      %{date: date, net_income: Decimal.sub(invoice_total, expense_total)}
    end)
  end

  attr :rest, :global
  defp no_records_state(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center px-4 py-14 text-center text-gray-500 sm:px-6" {@rest}>
      <img
        src={~p"/images/no.webp"}
        alt="Empty database"
        width="80"
        height="80"
        loading="lazy"
        decoding="async"
        fetchpriority="low"
        class="h-20 w-auto mb-4 mx-auto"
      />
      <p class="text-sm font-semibold text-gray-700">Record not found</p>
      <p class="mt-1 text-sm text-gray-500">Try another date or amount.</p>
    </div>
    """
  end

  attr :dialog_id, :string, required: true
  attr :dataset, :string, required: true
  attr :title, :string, required: true
  defp export_modal(assigns) do
    ~H"""
    <el-dialog>
      <dialog
        id={@dialog_id}
        aria-labelledby={"#{@dialog_id}-title"}
        class="fixed inset-0 size-auto max-h-none max-w-none overflow-y-auto bg-transparent backdrop:bg-transparent"
      >
        <el-dialog-backdrop class="fixed inset-0 bg-gray-500/75 transition-opacity data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in"></el-dialog-backdrop>

        <div tabindex="0" class="flex min-h-full items-end justify-center p-4 text-center focus:outline-none sm:items-center sm:p-0">
          <el-dialog-panel class="relative transform overflow-hidden rounded-lg bg-white text-left shadow-xl transition-all data-closed:translate-y-4 data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in sm:my-8 sm:w-full sm:max-w-lg data-closed:sm:translate-y-0 data-closed:sm:scale-95">
            <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
              <div class="sm:flex sm:items-start">
                <div class="mx-auto flex size-12 shrink-0 items-center justify-center rounded-full bg-gray-100 sm:mx-0 sm:size-10">
                  <.icon name="hero-arrow-down-tray" class="size-6 text-gray-700" />
                </div>

                <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                  <h3 id={"#{@dialog_id}-title"} class="text-base font-semibold text-gray-900">{@title}</h3>
                  <div class="mt-2">
                    <p class="text-sm text-gray-500">
                      Choose your preferred export format.
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <div class="bg-gray-50 px-4 py-3 sm:flex sm:flex-row-reverse sm:px-6">
              <a
                href={~p"/reports/export?dataset=#{@dataset}&format=csv"}
                class="inline-flex w-full justify-center rounded-md bg-black px-3 py-2 text-sm font-semibold text-white hover:bg-gray-900 sm:ml-3 sm:w-auto"
              >
                Export CSV
              </a>

              <a
                href={~p"/reports/export?dataset=#{@dataset}&format=pdf"}
                class="mt-3 inline-flex w-full justify-center rounded-md bg-amber-500 px-3 py-2 text-sm font-semibold text-white hover:bg-amber-600 sm:mt-0 sm:ml-3 sm:w-auto"
              >
                Export PDF
              </a>

              <button
                type="button"
                command="close"
                commandfor={@dialog_id}
                class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-xs inset-ring inset-ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto"
              >
                Cancel
              </button>
            </div>
          </el-dialog-panel>
        </div>
      </dialog>
    </el-dialog>
    """
  end

  defp card_title("spending"), do: "Spending Report"
  defp card_title("income"), do: "Income Report"
  defp card_title("net_income"), do: "Net Income Report"
  defp card_title("summary"), do: "Summary Report"

  defp card_subtitle("spending"), do: "By Finance"
  defp card_subtitle("income"), do: "By Finance"
  defp card_subtitle("net_income"), do: "By Finance"
  defp card_subtitle("summary"), do: "By Finance"

  defp card_description("spending", total_expenses, _total_invoices) do
    "Total expenses: #{format_amount(total_expenses)}"
  end

  defp card_description("net_income", _total_expenses, total_invoices) do
    "Total invoices: #{format_amount(total_invoices)}"
  end

  defp card_description("income", _total_expenses, _total_invoices) do
    "Income report section is ready for your next data additions."
  end

  defp card_description("summary", _total_expenses, _total_invoices) do
    "Summary report section is ready for your next data additions."
  end

  defp chart_bars("spending") do
    [
      %{label: "Operations", value: "82%", width_class: "w-10/12", color_class: "bg-amber-800"},
      %{label: "Transport", value: "58%", width_class: "w-7/12", color_class: "bg-gray-600"},
      %{label: "Misc", value: "33%", width_class: "w-4/12", color_class: "bg-gray-400"}
    ]
  end

  defp chart_bars("income") do
    [
      %{label: "Recurring", value: "76%", width_class: "w-9/12", color_class: "bg-amber-800"},
      %{label: "One-off", value: "41%", width_class: "w-5/12", color_class: "bg-gray-600"},
      %{label: "Pending", value: "19%", width_class: "w-2/12", color_class: "bg-gray-400"}
    ]
  end

  defp chart_bars("net_income") do
    [
      %{label: "Net", value: "68%", width_class: "w-8/12", color_class: "bg-amber-800"},
      %{label: "Expenses", value: "47%", width_class: "w-6/12", color_class: "bg-gray-600"},
      %{label: "Taxes", value: "29%", width_class: "w-3/12", color_class: "bg-gray-400"}
    ]
  end

  defp chart_bars("summary") do
    [
      %{label: "Coverage", value: "88%", width_class: "w-11/12", color_class: "bg-amber-800"},
      %{label: "Variance", value: "36%", width_class: "w-4/12", color_class: "bg-gray-600"},
      %{label: "Risk", value: "22%", width_class: "w-3/12", color_class: "bg-gray-400"}
    ]
  end

  defp format_invoice_date(%DateTime{} = issued_at) do
    issued_at
    |> DateTime.to_date()
    |> Calendar.strftime("%b %-d")
  end

  defp format_invoice_date(_), do: "-"

  defp decimal_or_zero(%Decimal{} = amount), do: amount
  defp decimal_or_zero(nil), do: Decimal.new(0)
  defp decimal_or_zero(amount), do: Decimal.new(amount)

  defp format_amount(%Decimal{} = amount), do: Decimal.to_string(amount, :normal)
  defp format_amount(amount), do: to_string(amount)
end
