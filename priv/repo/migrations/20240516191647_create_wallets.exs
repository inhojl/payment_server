defmodule PaymentServer.Repo.Migrations.CreateWalletsTable do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :currency, :string, null: false
      add :balance, :decimal, default: 0.00, null: false

      timestamps()
    end

    create index :wallets, [:user_id]
    create unique_index :wallets, [:user_id, :currency]
  end
end
