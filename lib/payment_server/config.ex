defmodule PaymentServer.Config do
  def currencies do
    Application.fetch_env!(:payment_server, :currencies)
  end

  def currencies_string_to_atom_map do
    currencies()
    |> Enum.map(&{Atom.to_string(&1), &1})
    |> Enum.into(%{})
  end

end
