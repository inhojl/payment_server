defmodule PaymentServerWeb.Middlewares.AuthMiddlewareTest do
  use ExUnit.Case, async: true

  alias PaymentServerWeb.Middlewares.AuthMiddleware


  describe "&call/2" do
    test "should return same resolution if there is secret key" do
      assert AuthMiddleware.call(%{context: %{secret_key: "Imsecret"}}, %{}) === %{context: %{secret_key: "Imsecret"}}
    end

    test "should return unauthorized if there incorrect secret key" do
      input_resolution = %Absinthe.Resolution{context: %{secret_key: "incorrect"}}

      expected_resolution = %Absinthe.Resolution{context: %{secret_key: "incorrect"}, state: :resolved, errors: [:unauthorized]}

      assert AuthMiddleware.call(input_resolution, %{}) === expected_resolution
    end

    test "should return unauthorized error if there is no secret key" do
      assert AuthMiddleware.call(%Absinthe.Resolution{}, %{}) === %Absinthe.Resolution{state: :resolved, errors: [:unauthorized]}
    end
  end


end
