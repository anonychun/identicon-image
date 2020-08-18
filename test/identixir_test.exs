defmodule IdentixirTest do
  use ExUnit.Case
  doctest Identixir

  test "generating image" do
    assert Identixir.generate("anonychun") == :ok
  end
end
