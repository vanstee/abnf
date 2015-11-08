defmodule ABNFTest do
  use ExUnit.Case
  alias ABNF.RFC5234
  alias ABNF.Generator

  doctest ABNF

  test "parsing and generating a dquote" do
    assert ["\""] = RFC5234.parse(:dquote, "\"") |> Generator.generate
  end

  test "parsing and generating a bit" do
    assert ["0"] = RFC5234.parse(:bit, "0") |> Generator.generate
    assert ["1"] = RFC5234.parse(:bit, "1") |> Generator.generate
  end

  test "parsing and generating a crlf" do
    assert ["\r\n"] = RFC5234.parse(:crlf, "\r\n") |> Generator.generate
  end

  test "parsing and generating a repeat" do
    assert ["1*23"] = RFC5234.parse(:repeat, "1*23") |> Generator.generate
  end
end
