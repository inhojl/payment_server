defmodule PaymentServer.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset
  alias PaymentServer.Accounts.Wallet

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
    |> unique_constraint([:email])
    |> cast_assoc(:wallets)
  end
end
