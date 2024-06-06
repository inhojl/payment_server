defmodule PaymentServer.Accounts.Transaction do
  use Ecto.Schema

  import Ecto.Changeset
  alias PaymentServer.Accounts.TransactionType

  schema "transactions" do
    field :user_id, :id, virtual: true
    field :wallet_id, :id, virtual: true
    field :currency, :string, virtual: true
    field :transaction_amount, :decimal, virtual: true
    field :transaction_type, Ecto.Enum, values: TransactionType.all(), virtual: true
    field :inserted_at, :utc_datetime, virtual: true
    field :updated_at, :utc_datetime, virtual: true
  end

  @required_params [
    :user_id,
    :wallet_id,
    :currency,
    :transaction_amount,
    :transaction_type,
    :inserted_at,
    :updated_at
  ]

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
  end

end
