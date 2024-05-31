defmodule PaymentServer.Apis.AlphaVantage do

  def get_exchange_rate(from_currency, to_currency) do
    with {:ok, %{status: 200, body: body}} <- Req.get(url: "http://localhost:4001/query", params: [
        function: "CURRENCY_EXCHANGE_RATE",
        from_currency: from_currency,
        to_currency: to_currency
        ])
    do
      exchange_rate = body["Realtime Currency Exchange Rate"]["5. Exchange Rate"]
      {:ok, exchange_rate}
    else
      {:ok, %{status: status, body: message} = resp} when status in 400..499 -> {:error, ErrorMessage.bad_request("[Apis.AlphaVantage.get_exchange_rate] #{status}: #{message}", resp)}
      {:ok, %{status: status, body: message} = resp} when status in 500..599 -> {:error, ErrorMessage.internal_server_error("[Apis.AlphVantage.get_exchange_rate] #{status}: #{message}", resp)}
      {:error, error} -> {:error, error}
    end

  end

end
