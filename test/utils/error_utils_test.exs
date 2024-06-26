defmodule Utils.ErrorUtilsTest do
  alias Utils.ErrorUtils
  use ExUnit.Case, async: true
  doctest ErrorUtils


  describe "&not_found/1" do
    test "returns correct payload" do
      assert ErrorUtils.not_found("test") === %{code: :not_found, message: "test"}
    end
  end

  describe "&not_found/2" do
    test "returns correct payload" do
      assert ErrorUtils.not_found("test", %{id: 1}) === %{code: :not_found, message: "test", details: %{id: 1}}
    end
  end

  describe "&bad_request/1" do
    test "returns correct payload" do
      assert ErrorUtils.bad_request("test") === %{code: :bad_request, message: "test"}
    end
  end

  describe "&bad_request/2" do
    test "returns correct payload" do
      assert ErrorUtils.bad_request("test", %{id: 1}) === %{code: :bad_request, message: "test", details: %{id: 1}}
    end
  end

  describe "&internal_server_error/1" do
    test "returns correct payload" do
      assert ErrorUtils.internal_server_error("test") === %{code: :internal_server_error, message: "test"}
    end
  end

  describe "&internal_server_error/2" do
    test "returns correct payload" do
      assert ErrorUtils.internal_server_error("test", %{id: 1}) === %{code: :internal_server_error, message: "test", details: %{id: 1}}
    end
  end

  describe "&conflict/1" do
    test "returns correct payload" do
      assert ErrorUtils.conflict("test") === %{code: :conflict, message: "test"}
    end
  end

  describe "&conflict/2" do
    test "returns correct payload" do
      assert ErrorUtils.conflict("test", %{id: 1}) === %{code: :conflict, message: "test", details: %{id: 1}}
    end
  end

  describe "&unauthorized/1" do
    test "returns correct payload" do
      assert ErrorUtils.unauthorized("test") === %{code: :unauthorized, message: "test"}
    end
  end

  describe "&unauthorized/2" do
    test "returns correct payload" do
      assert ErrorUtils.unauthorized("test", %{id: 1}) === %{code: :unauthorized, message: "test", details: %{id: 1}}
    end
  end


end
