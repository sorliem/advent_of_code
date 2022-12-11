defmodule MonkeyBusinessTest do
  use ExUnit.Case
  doctest MonkeyBusiness

  test "greets the world" do
    assert MonkeyBusiness.hello() == :world
  end
end
