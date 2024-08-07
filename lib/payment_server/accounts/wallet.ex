defmodule PaymentServer.Accounts.Wallet do
  alias PaymentServer.Config
  alias PaymentServer.Accounts.User
  alias PaymentServer.Accounts.Wallet
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @currencies Config.currencies()

  schema "wallets" do
    field :balance, :decimal, default: Decimal.new("0.00")
    field :currency, Ecto.Enum, values: @currencies

    belongs_to :user, User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:currency, :balance, :user_id])
    |> validate_required([:currency, :balance])
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> unique_constraint([:currency, :user_id])
  end

  def lock_by_user_id_and_currency(query \\ Wallet, user_id, currency) do
    query
    |> where([w], w.user_id == ^user_id)
    |> where([w], w.currency == ^currency)
    |> lock("FOR UPDATE")
  end
end
