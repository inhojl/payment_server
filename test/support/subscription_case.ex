defmodule PaymentServerWeb.SubscriptionCase do

  @moduledoc """
  Test Case for GraphQL subscription
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use PaymentServerWeb.ChannelCase

      use Absinthe.Phoenix.SubscriptionTest,
        schema: PaymentServerWeb.Schema

      setup do
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(PaymentServer.Repo)
        :ok = Ecto.Adapters.SQL.Sandbox.mode(PaymentServer.Repo, {:shared, self()})

        {:ok, socket} = Phoenix.ChannelTest.connect(PaymentServerWeb.UserSocket, %{})
        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)

        {:ok, %{socket: socket}}
      end

    end
  end
end
