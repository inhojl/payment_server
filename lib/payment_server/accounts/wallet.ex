defmodule PaymentServer.Accounts.Wallet do
  alias PaymentServer.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :balance, :decimal, default: Decimal.new("0.00")
    field :currency, :string

    belongs_to :user, User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:user_id, :currency, :balance])
    |> validate_required([:user_id, :currency, :balance])
  end
end
