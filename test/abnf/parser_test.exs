defmodule ABNF.ParserTest do
  use ExUnit.Case
  alias ABNF.RFC5234

  test "parsing a dquote" do
    assert {:dquote, "\"", []} = RFC5234.parse(:dquote, "\"")
  end
end
