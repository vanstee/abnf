defmodule AbnfTest do
  use ExUnit.Case
  alias Abnf.Rfc5234
  alias Abnf.Generator

  doctest Abnf

  test "finding a module name from a path" do
    assert Rfc2822 = Abnf.module_name("priv/rfc2822.abnf")
  end

  test "parsing and generating a dquote rule" do
    expected_rulelist = """
    defrule(:DQUOTE) do
      literal('"')
    end
    """ |> String.rstrip

    actual_rulelist = Rfc5234.parse(:rule, "DQUOTE = %x22\r\n")
    |> List.first
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
    |> List.first
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
    |> List.first
    |> Generator.generate
    |> Macro.to_string

    assert expected_rulelist == actual_rulelist
  end
end
