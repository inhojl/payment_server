defmodule PaymentServer.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias PaymentServer.Repo
  alias Ecto.Multi

  alias PaymentServer.Accounts.User
  alias EctoShorts.Actions

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(params) do
    {:ok, Actions.all(User, params)}
  end

  def find_user(params) do
    Actions.find(User, params)
  end

  def create_user(params) do
    Actions.create(User, params)
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias PaymentServer.Accounts.Wallet


  def list_wallets(params) do
    {:ok, Actions.all(Wallet, params)}
  end


  def find_wallet(params) do
    Actions.find(Wallet, params)
  end

  def create_wallet(params) do
    Actions.create(Wallet, params)
  end

  @doc """
  Updates a wallet.

  ## Examples

      iex> update_wallet(wallet, %{field: new_value})
      {:ok, %Wallet{}}

      iex> update_wallet(wallet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wallet(%Wallet{} = wallet, params) do
    Actions.update(Wallet, wallet, params)
  end

  @doc """
  Deletes a wallet.

  ## Examples

      iex> delete_wallet(wallet)
      {:ok, %Wallet{}}

      iex> delete_wallet(wallet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wallet(%Wallet{} = wallet) do
    Repo.delete(wallet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wallet changes.

  ## Examples

      iex> change_wallet(wallet)
      %Ecto.Changeset{data: %Wallet{}}

  """
  def change_wallet(%Wallet{} = wallet, attrs \\ %{}) do
    Wallet.changeset(wallet, attrs)
  end

  def send_money(sender_wallet, recipient_wallet, amount) do
    with {:ok, sender_wallet} <- find_wallet(sender_wallet),
         {:ok, recipient_wallet} <- find_wallet(recipient_wallet)
    do
      Multi.new()
      |> Multi.update(:update_sender_wallet, Wallet.changeset(sender_wallet, %{balance: Decimal.sub(sender_wallet.balance, amount)}))
      |> Multi.update(:update_recipient_wallet, Wallet.changeset(recipient_wallet, %{balance: Decimal.sub(recipient_wallet.balance, amount)}))
      |> Repo.transaction()
    end
  end
end
