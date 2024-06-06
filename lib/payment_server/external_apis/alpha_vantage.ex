defmodule PaymentServer.ExternalApis.AlphaVantage do
  @behaviour PaymentServer.Behaviours.AlphaVantage

  alias Utils.AccessExt
  @impl PaymentServer.Behaviours.AlphaVantage
  def get_exchange_rate(from_currency, to_currency) do
    with {:ok, body} <- handle_get_exchange_rate(from_currency, to_currency),
         {:ok, exchange_rate} <- handle_fetch_in(body, ["Realtime Currency Exchange Rate", "5. Exchange Rate"])
    do
      {:ok, Decimal.new(exchange_rate)}
    end
  end

  defp handle_get_exchange_rate(from_currency, to_currency) do
    params = [
      function: "CURRENCY_EXCHANGE_RATE",
      from_currency: from_currency,
      to_currency: to_currency
    ]
    case Req.get(url: "http://localhost:4001/query", params: params) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status, body: message} = resp} when status in 400..499 ->
        {:error, ErrorMessage.bad_request(
          external_error_message(__MODULE__, __ENV__.function, status, message),
          resp
        )}

      {:ok, %{status: status, body: message} = resp} ->
        {:error, ErrorMessage.internal_server_error(
          external_error_message(__MODULE__, __ENV__.function, status, message),
          {:internal, resp}
        )}

      {:error, error} when is_exception(error) ->
        {:error, ErrorMessage.internal_server_error(
          unknown_error_message(__MODULE__, __ENV__.function),
          {:internal, error}
        )}
    end
  end

  defp handle_fetch_in(body, key_list) do
    case AccessExt.fetch_in(body, key_list) do
      {:ok, value} -> {:ok, value}
      {:error, key} ->
        {function_name, arity} = __ENV__.function
        {:error, ErrorMessage.not_found(
          "[#{__MODULE__}.#{function_name}/#{arity}] Failed at key #{key} while traversing body",
          :internal
        )}
    end
  end

  defp unknown_error_message(module, {function_name, arity}) do
    "[#{module}.#{function_name}/#{arity}] Unknown server error"
  end

  defp external_error_message(module, {function_name, arity}, status, message) do
    "[#{module}.#{function_name}/#{arity}] External #{status}: #{message}"
  end

end
