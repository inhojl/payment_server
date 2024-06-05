defmodule PaymentServerWeb.Middlewares.CurrencyValidator do
  alias PaymentServer.Config
  @behaviour Absinthe.Middleware

  @currencies_string_to_atom_map Config.currencies_string_to_atom_map()
  @currency_args_to_validate [:currency, :recipient_currency, :sender_currency]

  def call(%{arguments: args} = resolution, _config) do
    # { currency: "USD" }

    invalid_args = args
      |> filter_currency_args()
      |> filter_invalid_args()

    case invalid_args do
      [] -> resolution
      invalid_args -> Absinthe.Resolution.put_result(resolution, {:error, ErrorMessage.bad_request(error_message(invalid_args), invalid_args)})
    end
  end

  defp error_message(invalid_args) do
    invalid_args
    |> Enum.map(fn {key, currency_string} -> "#{key}: #{currency_string}" end)
    |> Enum.join(", ")
    |> then(&("Invalid currency - #{&1}"))
  end

  defp filter_currency_args(args) do
    Enum.filter(args, fn {key, _} -> key in @currency_args_to_validate end)
  end

  defp filter_invalid_args(args) do
    Enum.filter(args, fn {_key, currency_string} -> not Map.has_key?(@currencies_string_to_atom_map, currency_string) end)
  end

end
