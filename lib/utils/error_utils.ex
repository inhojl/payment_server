defmodule Utils.ErrorUtils do

  def not_found(message), do: error_payload(:not_found, message)
  def not_found(message, details), do: error_payload(:not_found, message, details)

  def bad_request(message), do: error_payload(:bad_request, message)
  def bad_request(message, details), do: error_payload(:bad_request, message, details)

  def internal_server_error(message), do: error_payload(:internal_server_error, message)
  def internal_server_error(message, details), do: error_payload(:internal_server_error, message, details)

  def conflict(message), do: error_payload(:conflict, message)
  def conflict(message, details), do: error_payload(:conflict, message, details)

  def unauthorized(message), do: error_payload(:unauthorized, message)
  def unauthorized(message, details), do: error_payload(:unauthorized, message, details)

  defp error_payload(code, message, details) do
    %{
      code: code,
      message: message,
      details: details
    }
  end

  defp error_payload(code, message) do
    %{
      code: code,
      message: message
    }
  end

end
