defmodule PaymentServerWeb.Types.IntegerId do
  use Absinthe.Schema.Notation

  scalar :integer_id, description: "A scalar type for Integer IDs" do
    parse &parse_id/1
    serialize &serialize_id/1
  end

  defp parse_id(%Absinthe.Blueprint.Input.Integer{value: value}) when is_integer(value), do: {:ok, value}
  defp parse_id(%Absinthe.Blueprint.Input.String{value: value}) do
    case Integer.parse(value) do
      {int, ""} -> {:ok, int}
      _ -> :error
    end
  end
  defp parse_id(_), do: :error

  defp serialize_id(int) when is_integer(int), do: int
  defp serialize_id(_), do: :error
end
