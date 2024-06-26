defmodule PaymentServerWeb.Middlewares.ErrorHandler do
  @behaviour Absinthe.Middleware

  alias Ecto.Changeset
  alias Utils.ErrorUtils

  require Logger

  def call(%{errors: errors} = resolution, _config) do
    transformed_errors = Enum.map(errors, &transform_error/1)

    %{resolution | errors: transformed_errors}
  end

  defp transform_error(%Changeset{
         errors: [email: {_, [constraint: :unique, constraint_name: _]}] = errors
       }) do
    errors
    |> format_changeset_errors()
    |> tap(&Logger.debug/1)
    |> then(fn message -> ErrorUtils.conflict(message) end)
  end

  defp transform_error(%Changeset{errors: errors} = changeset) do
    errors
    |> format_changeset_errors()
    |> tap(&Logger.debug/1)
    |> then(fn message -> ErrorUtils.bad_request(message, changeset.changes) end)
  end

  defp transform_error(%ErrorMessage{details: {:internal, _}} = error),
    do: handle_internal_error(error)

  defp transform_error(%ErrorMessage{details: :internal} = error),
    do: handle_internal_error(error)

  defp transform_error(%ErrorMessage{code: :not_found, details: %{params: %{id: id}}} = error) do
    ErrorUtils.not_found(error.message, %{id: id})
  end

  defp transform_error(%ErrorMessage{} = error) do
    ErrorMessage.to_jsonable_map(error)
  end

  defp transform_error(:unauthorized) do
    ErrorUtils.unauthorized("unauthorized")
  end

  defp transform_error(error) do
    handle_internal_error(error)
  end

  defp handle_internal_error(%ErrorMessage{} = error) do
    Logger.error(error)
    ErrorMessage.to_jsonable_map(error)
  end

  defp handle_internal_error(error) do
    Logger.error(error)
    ErrorUtils.internal_server_error("internal server error")
  end

  defp format_changeset_errors(errors) do
    Enum.map_join(errors, ", ", fn {field, {field_error_message, _}} ->
      "#{field} #{field_error_message}"
    end)
  end
end
