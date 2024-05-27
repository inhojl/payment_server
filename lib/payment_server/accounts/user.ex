defmodule PaymentServer.Accounts.User do
  alias PaymentServer.Accounts.Wallet
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string

    has_many :wallets, Wallet
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> cast_assoc(:wallets)
  end
end
