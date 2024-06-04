defmodule PaymentServerWeb.Middlewares.ErrorHandler do
  @behaviour Absinthe.Middleware

  def call(resolution, _config) do
    IO.inspect resolution.errors
    handle_error(resolution)
  end


  def handle_error(resolution) do

  end

end
