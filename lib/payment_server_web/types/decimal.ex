defmodule PaymentServerWeb.Types.Decimal do
  use Absinthe.Schema.Notation

  scalar :decimal, description: "A custom scalar type for decimal values" do
    parse &parse_decimal/1
    serialize &serialize_decimal/1
  end

  defp parse_decimal(%Absinthe.Blueprint.Input.String{value: value}), do: Decimal.cast(value)
  defp parse_decimal(_), do: :error

  defp serialize_decimal(%Decimal{} = decimal), do: Decimal.to_string(decimal)
  defp serialize_decimal(_), do: :error

end
