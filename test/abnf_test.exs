defmodule AbnfTest do
  use ExUnit.Case
  alias Abnf.Rfc5234
  alias Abnf.Generator

  doctest Abnf

  test "finding a module name from a path" do
    assert Rfc2822 = Abnf.module_name("priv/rfc2822.abnf")
  end

  test "parsing and generating a dquote" do
    assert "\"" = Rfc5234.parse(:DQUOTE, "\"") |> Generator.generate
  end

  test "parsing and generating a bit" do
    assert "0" = Rfc5234.parse(:BIT, "0") |> Generator.generate
    assert "1" = Rfc5234.parse(:BIT, "1") |> Generator.generate
  end

  test "parsing and generating a crlf" do
    assert "\r\n" = Rfc5234.parse(:CRLF, "\r\n") |> Generator.generate
  end

  test "parsing and generating a repeat" do
    assert "1*23" = Rfc5234.parse(:repeat, "1*23") |> Generator.generate
  end

  test "parsing and generating a dquote rule" do
    expected_rulelist = """
    defrule(:DQUOTE) do
      literal('"')
    end
    """
    |> String.rstrip

    actual_rulelist = Rfc5234.parse(:rule, "DQUOTE = %x22\r\n")
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

    actual_rulelist = Rfc5234.parse(:rule, ~s(BIT = "0" / "1"\r\n))
    |> Generator.generate
    |> Macro.to_string

    assert expected_rulelist == actual_rulelist
  end

  test "parsing and generating rfc5234" do
    module = Abnf.load("priv/rfc5234.abnf")

    expected_rulelist = """
    defrule(:DQUOTE) do
      literal('"')
    end
    """
    |> String.rstrip

    actual_rulelist = module.parse(:rule, "DQUOTE = %x22\r\n")
    |> Generator.generate
    |> Macro.to_string

    assert expected_rulelist == actual_rulelist
  end
end
