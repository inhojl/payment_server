defmodule PaymentServerWeb.Middlewares.ErrorHandler do
  alias Ecto.Changeset
  @behaviour Absinthe.Middleware

  require Logger

  def call(%{errors: errors} = resolution, _config) do
    transformed_errors =
      errors
      |> Enum.map(&transform_error/1)

    %{resolution | errors: transformed_errors}
  end

  defp transform_error(%ErrorMessage{details: {:internal, _}} = error), do: handle_internal_error(error)
  defp transform_error(%ErrorMessage{details: :internal} = error), do: handle_internal_error(error)
  defp transform_error(%ErrorMessage{} = error) do
    Logger.debug(ErrorMessage.to_jsonable_map(error))
    %{
      code: error.code,
      message: error.message
    }
  end
  defp transform_error(%Changeset{errors: errors}) do
    errors
    |> Enum.map(fn {field, {field_error_message, _}} -> "#{field}: #{field_error_message}" end)
    |> Enum.join(", ")
    |> tap(&Logger.debug/1)
    |> then(&%{message: &1})
  end

  defp handle_internal_error(error) do
    Logger.error(ErrorMessage.to_jsonable_map(error))
    %{
      code: :internal_server_error,
      message: "Internal server error"
    }
  end


end
