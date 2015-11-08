defmodule ABNF.GeneratorTest do
  use ExUnit.Case
  alias ABNF.Generator

  test "generating a dquote" do
    assert "\"" = Generator.generate({:dquote, "\"", []})
  end
end
