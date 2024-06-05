defmodule PaymentServerWeb.Middlewares.ErrorHandler do
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

  defp handle_internal_error(error) do
    Logger.error(ErrorMessage.to_jsonable_map(error))
    %{
      code: :internal_server_error,
      message: "Internal server error"
    }
  end


end
