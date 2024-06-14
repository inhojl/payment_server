defmodule PaymentServerWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: PaymentServerWeb.Schema

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket) do
    # IO.puts(socket[:id])
  end
end
