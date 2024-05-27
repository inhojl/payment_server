defmodule PaymentServerWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ChannelTest

      @endpoint PaymentServerWeb.Endpoint
    end
  end

end
