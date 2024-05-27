defmodule PaymentServer.Accounts.Wallet do
  alias PaymentServer.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :balance, :decimal
    field :currency, :string

    belongs_to :user, User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:currency, :balance])
    |> validate_required([:currency, :balance])
  end
end
