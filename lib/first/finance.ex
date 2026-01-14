defmodule First.Finance do
  @moduledoc """
  The Finance context.
  """

  import Ecto.Query, warn: false
  alias First.Repo

  alias First.Finance.Expense
  alias First.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any expense changes.

  The broadcasted messages match the pattern:

    * {:created, %Expense{}}
    * {:updated, %Expense{}}
    * {:deleted, %Expense{}}

  """
  def subscribe_expenses(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(First.PubSub, "user:#{key}:expenses")
  end

  defp broadcast_expense(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(First.PubSub, "user:#{key}:expenses", message)
  end

  @doc """
  Returns the list of expenses.

  ## Examples

      iex> list_expenses(scope)
      [%Expense{}, ...]

  """
  def list_expenses(%Scope{} = scope) do
    Repo.all_by(Expense, user_id: scope.user.id)
  end

  @doc """
  Gets a single expense.

  Raises `Ecto.NoResultsError` if the Expense does not exist.

  ## Examples

      iex> get_expense!(scope, 123)
      %Expense{}

      iex> get_expense!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_expense!(%Scope{} = scope, id) do
    Repo.get_by!(Expense, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a expense.

  ## Examples

      iex> create_expense(scope, %{field: value})
      {:ok, %Expense{}}

      iex> create_expense(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_expense(%Scope{} = scope, attrs) do
    with {:ok, expense = %Expense{}} <-
           %Expense{}
           |> Expense.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_expense(scope, {:created, expense})
      {:ok, expense}
    end
  end

  @doc """
  Updates a expense.

  ## Examples

      iex> update_expense(scope, expense, %{field: new_value})
      {:ok, %Expense{}}

      iex> update_expense(scope, expense, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_expense(%Scope{} = scope, %Expense{} = expense, attrs) do
    true = expense.user_id == scope.user.id

    with {:ok, expense = %Expense{}} <-
           expense
           |> Expense.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_expense(scope, {:updated, expense})
      {:ok, expense}
    end
  end

  @doc """
  Deletes a expense.

  ## Examples

      iex> delete_expense(scope, expense)
      {:ok, %Expense{}}

      iex> delete_expense(scope, expense)
      {:error, %Ecto.Changeset{}}

  """
  def delete_expense(%Scope{} = scope, %Expense{} = expense) do
    true = expense.user_id == scope.user.id

    with {:ok, expense = %Expense{}} <-
           Repo.delete(expense) do
      broadcast_expense(scope, {:deleted, expense})
      {:ok, expense}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking expense changes.

  ## Examples

      iex> change_expense(scope, expense)
      %Ecto.Changeset{data: %Expense{}}

  """
  def change_expense(%Scope{} = scope, %Expense{} = expense, attrs \\ %{}) do
    true = expense.user_id == scope.user.id

    Expense.changeset(expense, attrs, scope)
  end

  alias First.Finance.Invoice
  alias First.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any invoice changes.

  The broadcasted messages match the pattern:

    * {:created, %Invoice{}}
    * {:updated, %Invoice{}}
    * {:deleted, %Invoice{}}

  """
  def subscribe_invoices(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(First.PubSub, "user:#{key}:invoices")
  end

  defp broadcast_invoice(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(First.PubSub, "user:#{key}:invoices", message)
  end

  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices(scope)
      [%Invoice{}, ...]

  """
  def list_invoices(%Scope{} = scope) do
    Repo.all_by(Invoice, user_id: scope.user.id)
  end

  @doc """
  Gets a single invoice.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice!(scope, 123)
      %Invoice{}

      iex> get_invoice!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice!(%Scope{} = scope, id) do
    Repo.get_by!(Invoice, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a invoice.

  ## Examples

      iex> create_invoice(scope, %{field: value})
      {:ok, %Invoice{}}

      iex> create_invoice(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice(%Scope{} = scope, attrs) do
    with {:ok, invoice = %Invoice{}} <-
           %Invoice{}
           # <-- pass scope here
           |> Invoice.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_invoice(scope, {:created, invoice})
      {:ok, invoice}
    end
  end

  @doc """
  Updates a invoice.

  ## Examples

      iex> update_invoice(scope, invoice, %{field: new_value})
      {:ok, %Invoice{}}

      iex> update_invoice(scope, invoice, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invoice(%Scope{} = scope, %Invoice{} = invoice, attrs) do
    true = invoice.user_id == scope.user.id

    with {:ok, invoice = %Invoice{}} <-
           invoice
           |> Invoice.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_invoice(scope, {:updated, invoice})
      {:ok, invoice}
    end
  end

  @doc """
  Deletes a invoice.

  ## Examples

      iex> delete_invoice(scope, invoice)
      {:ok, %Invoice{}}

      iex> delete_invoice(scope, invoice)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice(%Scope{} = scope, %Invoice{} = invoice) do
    true = invoice.user_id == scope.user.id

    with {:ok, invoice = %Invoice{}} <-
           Repo.delete(invoice) do
      broadcast_invoice(scope, {:deleted, invoice})
      {:ok, invoice}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.

  ## Examples

      iex> change_invoice(scope, invoice)
      %Ecto.Changeset{data: %Invoice{}}

  """
  def change_invoice(%Scope{} = scope, %Invoice{} = invoice, attrs \\ %{}) do
    # true = invoice.user_id == scope.user.id  <-- REMOVE THIS
    Invoice.changeset(invoice, attrs, scope)
  end

  def total_invoices(scope) do
    Repo.one(
      from i in Invoice,
        where: i.user_id == ^scope.user.id,
        select: sum(i.amount)
    ) || 0
  end
end
