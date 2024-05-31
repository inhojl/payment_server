defmodule PaymentServer.Config do
  def currencies do
    Application.fetch_env!(:payment_server, :currencies)
  end
end
