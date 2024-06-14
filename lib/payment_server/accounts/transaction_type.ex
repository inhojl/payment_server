defmodule PaymentServer.Accounts.TransactionType do
  @transaction_types [:debit, :credit]

  def all, do: @transaction_types

  def credit, do: :credit

  def debit, do: :debit

  def valid?(type), do: type in @transaction_types
end
