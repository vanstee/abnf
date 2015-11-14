defmodule ABNFTest do
  use ExUnit.Case
  alias ABNF.RFC5234
  alias ABNF.Generator

  doctest ABNF

  test "parsing and generating a dquote" do
    assert "\"" = RFC5234.parse(:dquote, "\"") |> Generator.generate
  end

  test "parsing and generating a bit" do
    assert "0" = RFC5234.parse(:bit, "0") |> Generator.generate
    assert "1" = RFC5234.parse(:bit, "1") |> Generator.generate
  end

  test "parsing and generating a crlf" do
    assert "\r\n" = RFC5234.parse(:crlf, "\r\n") |> Generator.generate
  end

  test "parsing and generating a repeat" do
    assert "1*23" = RFC5234.parse(:repeat, "1*23") |> Generator.generate
  end

  test "parsing and generating a dquote rule" do
    expected_rulelist = """
    defrule(:DQUOTE) do
      literal('"')
    end
    """
    |> String.rstrip

    actual_rulelist = RFC5234.parse(:rulelist, "DQUOTE = %x22\r\n")
    |> Generator.generate
    |> Macro.to_string

    assert expected_rulelist == actual_rulelist
  end

  test "parsing and generating a bit rule" do
    expected_rulelist = """
    defrule(:BIT) do
      alternate([literal('0'), literal('1')])
    end
    """
    |> String.rstrip

    actual_rulelist = RFC5234.parse(:rulelist, ~s(BIT = "0" / "1"\r\n))
    |> Generator.generate
    |> Macro.to_string

    assert expected_rulelist == actual_rulelist
  end

  test "parsing and generating rfc5234" do
    assert :ok = Macro.validate(ABNF.load!("priv/rfc5234.abnf"))
  end
end
