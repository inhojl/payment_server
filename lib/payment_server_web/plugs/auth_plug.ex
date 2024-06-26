defmodule AuthPlug do
  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(default), do: default

  @impl Plug
  def call(conn, _) do
    case get_secret_key(conn) do
      {:error, _} ->
        conn

      {:ok, secret_key} ->
        Absinthe.Plug.put_options(conn, context: %{secret_key: secret_key})
    end
  end

  def get_secret_key(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        {:ok, token}

      _ ->
        {:error, :no_token}
    end
  end
end
