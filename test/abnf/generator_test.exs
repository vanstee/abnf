defmodule ABNF.GeneratorTest do
  use ExUnit.Case
  alias ABNF.Generator

  test "generating a dquote" do
    assert "\"" = Generator.generate({:dquote, "\"", []})
  end

  test "generating a bit" do
    assert "0" = Generator.generate({:bit, "0", []})
    assert "1" = Generator.generate({:bit, "1", []})
  end
end
