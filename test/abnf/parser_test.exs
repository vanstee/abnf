defmodule ABNF.ParserTest do
  use ExUnit.Case
  alias ABNF.RFC5234

  test "parsing a dquote" do
    assert {:dquote, "\"", []} = RFC5234.parse(:dquote, "\"")
  end

  test "parsing a bit" do
    assert {:bit, "0", []} = RFC5234.parse(:bit, "0")
    assert {:bit, "1", []} = RFC5234.parse(:bit, "1")
  end
end
