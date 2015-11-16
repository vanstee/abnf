defmodule Abnf.ParserTest do
  use ExUnit.Case, async: true
  alias Abnf.Rfc5234

  test "parsing a dquote" do
    assert [{:DQUOTE, "\"", []}] = Rfc5234.parse(:DQUOTE, "\"")
  end

  test "parsing a bit" do
    assert [{:BIT, "0", []}] = Rfc5234.parse(:BIT, "0")
    assert [{:BIT, "1", []}] = Rfc5234.parse(:BIT, "1")
  end

  test "parsing a crlf" do
    assert [{:CRLF, "\r\n", [
      {:CR, "\r", []},
      {:LF, "\n", []},
    ]}] = Rfc5234.parse(:CRLF, "\r\n")
  end

  test "parsing a repeat" do
    assert [{:repeat, "1*23", [
      {:DIGIT, "1", []},
      {:literal, "*", []},
      {:DIGIT, "2", []},
      {:DIGIT, "3", []}
    ]}] = Rfc5234.parse(:repeat, "1*23")
  end

  test "parsing a rulename" do
    assert [{:rulename, "DQUOTE", [
      {:ALPHA, "D", []},
      {:ALPHA, "Q", []},
      {:ALPHA, "U", []},
      {:ALPHA, "O", []},
      {:ALPHA, "T", []},
      {:ALPHA, "E", []}
    ]}] = Rfc5234.parse(:rulename, "DQUOTE")
  end

  test "parsing a rulelist" do
    assert [{:rulelist, _, [
      {:rule, "DQUOTE = %x22\r\n", [
        {:rulename, "DQUOTE", _},
        {:"defined-as", " = ", _},
        {:elements, _, [
          {:alternation, _, [
            {:concatenation, _, [
              {:repetition, _, [
                {:element, _, [
                  {:"num-val", "%x22", _},
                ]},
              ]},
            ]},
          ]},
        ]},
        {:"c-nl", "\r\n", _}
      ]}
    ]}] = Rfc5234.parse(:rulelist, "DQUOTE = %x22\r\n")
  end
end
