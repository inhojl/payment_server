defmodule PaymentServer.Accounts.Wallet do
  alias PaymentServer.Accounts.User
  alias PaymentServer.Accounts.Wallet
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "wallets" do
    field :balance, :decimal, default: Decimal.new("0.00")
    field :currency, :string

    belongs_to :user, User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:currency, :balance, :user_id])
    |> validate_required([:currency, :balance])
    |> validate_number(:balance, greater_than: 0)
  end

  def lock_by_user_id_and_currency(query \\ Wallet, user_id, currency) do
    query
    |> where([w], w.user_id == ^user_id)
    |> where([w], w.currency == ^currency)
    |> lock("FOR UPDATE")
  end


end
