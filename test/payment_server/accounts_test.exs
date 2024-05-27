defmodule PaymentServer.AccountsTest do
  use PaymentServer.DataCase, async: true

  alias PaymentServer.Accounts


  setup do
    assert {:ok, user1} = Accounts.create_user(%{email: "user1@email.com"})
    assert {:ok, user2} = Accounts.create_user(%{email: "user2@email.com"})
    %{user1: user1, user2: user2}
  end

  describe "&list_users/1" do
    test "fetches all users from the db" do
      assert {:ok, [user1, user2]} = Accounts.list_users(%{})
      assert user1.email === "user1@email.com"
      assert user2.email === "user2@email.com"
    end
  end

  describe "&find_user/1" do
    test "fetch user by id", %{user1: user1} do
      assert {:ok, user} = Accounts.find_user(%{id: user1.id})
      assert user.email === "user1@email.com"
    end

    test "fetch user by email", %{user2: user2} do
      assert {:ok, user} = Accounts.find_user(%{email: user2.email})
      assert user.id === user2.id
    end

  end


end
