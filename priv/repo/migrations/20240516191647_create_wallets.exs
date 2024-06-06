defmodule PaymentServer.Repo.Migrations.CreateWalletsTable do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :currency, :string
      add :balance, :decimal

      timestamps()
    end

    create index :wallets, [:user_id]
    create unique_index :wallets, [:currency, :user_id]
  end
end
