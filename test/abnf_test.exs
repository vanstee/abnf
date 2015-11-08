defmodule ABNFTest do
  use ExUnit.Case
  alias ABNF.RFC5234
  alias ABNF.Generator

  doctest ABNF

  test "parsing and generating a dquote" do
    assert "\"" = RFC5234.parse(:dquote, "\"") |> Generator.generate
  end
end
