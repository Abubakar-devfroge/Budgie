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
end
