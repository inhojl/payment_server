defmodule PaymentServerWeb.Middlewares.AuthMiddleware do
  @behaviour Absinthe.Middleware

  @impl Absinthe.Middleware
  def call(%{context: %{secret_key: bearer_secret}} = resolution, _config) do
    if bearer_secret === "Imsecret" do
      resolution
    else
      Absinthe.Resolution.put_result(resolution, {:error, :unauthorized})
    end
  end

  def call(resolution, _config) do
    Absinthe.Resolution.put_result(resolution, {:error, :unauthorized})
  end
end
