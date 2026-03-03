defmodule FirstWeb.ReportExportController do
  use FirstWeb, :controller

  alias First.Finance

  def export(conn, %{"dataset" => dataset, "format" => format}) do
    scope = conn.assigns.current_scope

    case build_export(scope, dataset, format) do
      {:ok, filename, content_type, body} ->
        conn
        |> put_resp_content_type(content_type)
        |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
        |> send_resp(200, body)

      :error ->
        conn
        |> put_flash(:error, "Unknown export request")
        |> redirect(to: ~p"/reports")
    end
  end

  def export(conn, _params) do
    conn
    |> put_flash(:error, "Please choose dataset and format")
    |> redirect(to: ~p"/reports")
  end

  defp build_export(scope, "expenses", "csv") do
    rows =
      Finance.list_expenses(scope)
      |> Enum.map(fn expense ->
        [Date.to_iso8601(expense.date), decimal_to_string(expense.total)]
      end)

    {:ok, "expenses.csv", "text/csv", csv(["date", "expense"], rows)}
  end

  defp build_export(scope, "invoices", "csv") do
    rows =
      Finance.list_invoices(scope)
      |> Enum.map(fn invoice ->
        [format_datetime(invoice.issued_at), decimal_to_string(invoice.amount)]
      end)

    {:ok, "invoices.csv", "text/csv", csv(["date", "invoice"], rows)}
  end

  defp build_export(scope, "net_income", "csv") do
    expenses = Finance.list_expenses(scope)
    invoices = Finance.list_invoices(scope)

    rows =
      build_net_income_rows(expenses, invoices)
      |> Enum.map(fn row ->
        [Date.to_iso8601(row.date), decimal_to_string(row.net_income)]
      end)

    {:ok, "net_income.csv", "text/csv", csv(["date", "net_income"], rows)}
  end

  defp build_export(scope, dataset, "pdf") when dataset in ["expenses", "invoices", "net_income"] do
    {headers, rows} = rows_for_dataset(scope, dataset)
    title = String.replace(dataset, "_", " ") |> String.upcase()

    {:ok,
     "#{dataset}.pdf",
     "application/pdf",
     simple_pdf("#{title} REPORT", [headers | rows])}
  end

  defp build_export(_scope, _dataset, _format), do: :error

  defp rows_for_dataset(scope, "expenses") do
    rows =
      Finance.list_expenses(scope)
      |> Enum.map(fn expense ->
        [Date.to_iso8601(expense.date), decimal_to_string(expense.total)]
      end)

    {["date", "expense"], rows}
  end

  defp rows_for_dataset(scope, "invoices") do
    rows =
      Finance.list_invoices(scope)
      |> Enum.map(fn invoice ->
        [format_datetime(invoice.issued_at), decimal_to_string(invoice.amount)]
      end)

    {["date", "invoice"], rows}
  end

  defp rows_for_dataset(scope, "net_income") do
    expenses = Finance.list_expenses(scope)
    invoices = Finance.list_invoices(scope)

    rows =
      build_net_income_rows(expenses, invoices)
      |> Enum.map(fn row ->
        [Date.to_iso8601(row.date), decimal_to_string(row.net_income)]
      end)

    {["date", "net_income"], rows}
  end

  defp csv(headers, rows) do
    [
      Enum.join(headers, ","),
      "\n",
      Enum.map(rows, fn row ->
        row
        |> Enum.map(&csv_escape/1)
        |> Enum.join(",")
      end)
      |> Enum.join("\n")
    ]
    |> IO.iodata_to_binary()
  end

  defp csv_escape(value) do
    text = to_string(value)

    if String.contains?(text, [",", "\n", "\""]) do
      escaped = String.replace(text, "\"", "\"\"")
      ~s("#{escaped}")
    else
      text
    end
  end

  defp format_datetime(%DateTime{} = value), do: DateTime.to_iso8601(value)
  defp format_datetime(_), do: ""

  defp decimal_to_string(%Decimal{} = value), do: Decimal.to_string(value, :normal)
  defp decimal_to_string(nil), do: "0"
  defp decimal_to_string(value), do: to_string(value)

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

  defp decimal_or_zero(%Decimal{} = amount), do: amount
  defp decimal_or_zero(nil), do: Decimal.new(0)
  defp decimal_or_zero(amount), do: Decimal.new(amount)

  defp simple_pdf(title, rows) do
    lines =
      [title | Enum.map(rows, fn row -> Enum.join(row, " | ") end)]
      |> Enum.take(45)

    text_ops =
      lines
      |> Enum.with_index()
      |> Enum.map(fn {line, index} ->
        escaped = line |> String.replace("\\", "\\\\") |> String.replace("(", "\\(") |> String.replace(")", "\\)")
        "BT /F1 11 Tf 50 #{770 - index * 16} Td (#{escaped}) Tj ET"
      end)
      |> Enum.join("\n")

    stream = "q\n#{text_ops}\nQ"
    len = byte_size(stream)

    obj1 = "1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n"
    obj2 = "2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj\n"
    obj3 =
      "3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >> endobj\n"
    obj4 = "4 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj\n"
    obj5 = "5 0 obj << /Length #{len} >> stream\n#{stream}\nendstream endobj\n"

    objects = [obj1, obj2, obj3, obj4, obj5]

    {body, offsets, _} =
      Enum.reduce(objects, {"", [], 9}, fn obj, {acc, offs, pos} ->
        {acc <> obj, offs ++ [pos], pos + byte_size(obj)}
      end)

    xref =
      ["xref\n0 6\n0000000000 65535 f \n"] ++
        Enum.map(offsets, fn off -> :io_lib.format("~10..0B 00000 n \n", [off]) end)

    trailer = "trailer << /Size 6 /Root 1 0 R >>\nstartxref\n#{9 + byte_size(body)}\n%%EOF"

    "%PDF-1.4\n" <> body <> IO.iodata_to_binary(xref) <> trailer
  end
end
