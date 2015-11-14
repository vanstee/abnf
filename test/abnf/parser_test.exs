defmodule ABNF.ParserTest do
  use ExUnit.Case
  alias ABNF.RFC5234

  test "parsing a dquote" do
    assert [{:dquote, "\"", []}] = RFC5234.parse(:dquote, "\"")
  end

  test "parsing a bit" do
    assert [{:bit, "0", []}] = RFC5234.parse(:bit, "0")
    assert [{:bit, "1", []}] = RFC5234.parse(:bit, "1")
  end

  test "parsing a crlf" do
    assert [{:crlf, "\r\n", [
      {:cr, "\r", []},
      {:lf, "\n", []},
    ]}] = RFC5234.parse(:crlf, "\r\n")
  end

  test "parsing a repeat" do
    assert [{:repeat, "1*23", [
      {:digit, "1", []},
      {:literal, "*", []},
      {:digit, "2", []},
      {:digit, "3", []}
    ]}] = RFC5234.parse(:repeat, "1*23")
  end

  test "parsing a rulename" do
    assert [{:rulename, "DQUOTE", [
      {:alpha, "D", []},
      {:alpha, "Q", []},
      {:alpha, "U", []},
      {:alpha, "O", []},
      {:alpha, "T", []},
      {:alpha, "E", []}
    ]}] = RFC5234.parse(:rulename, "DQUOTE")
  end

  test "parsing a rulelist" do
    assert [{:rulelist, _, [
      {:rule, "DQUOTE = %x22\r\n", [
        {:rulename, "DQUOTE", _},
        {:"defined-as", " = ", _},
        {:elements, _, [{:"num-val", "%x22", _}]},
        {:"c-nl", "\r\n", _}
      ]}
    ]}] = RFC5234.parse(:rulelist, "DQUOTE = %x22\r\n")
  end
end
