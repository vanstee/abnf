defmodule Abnf.GeneratorTest do
  use ExUnit.Case
  alias Abnf.Generator

  test "generating a dquote" do
    assert "\"" = Generator.generate({:DQUOTE, "\"", []})
  end

  test "generating a bit" do
    assert "0" = Generator.generate({:BIT, "0", []})
    assert "1" = Generator.generate({:BIT, "1", []})
  end

  test "generating a crlf" do
    assert "\r\n" = Generator.generate({:CRLF, "\r\n", [
      {:CR, "\r", []},
      {:LF, "\n", []},
    ]})
  end

  test "generating a repeat" do
    assert "1*23" = Generator.generate({:repeat, "1*23", [
      {:DIGIT, "1", []},
      {:literal, "*", []},
      {:DIGIT, "2", []},
      {:DIGIT, "3", []}
    ]})
  end

  test "generating a rulelist" do
    expected_rulelist = """
    defrule(:DQUOTE) do
      literal('"')
    end
    """ |> String.rstrip

    generated_rulelist = Generator.generate({:rule, "DQUOTE = %x22\r\n", [
      {:rulename, "DQUOTE", [
        {:ALPHA, "D", []},
        {:ALPHA, "Q", []},
        {:ALPHA, "U", []},
        {:ALPHA, "O", []},
        {:ALPHA, "T", []},
        {:ALPHA, "E", []}
      ]},
      {:"defined-as", " = ", [
        {:"c-wsp", " ", [
          {:WSP, " ", [
            {:SP, " ", []}
          ]}
        ]},
        {:literal, "=", []},
        {:"c-wsp", " ", [
          {:WSP, " ", [
            {:SP, " ", []}
          ]}
        ]}
      ]},
      {:elements, "%x22", [
        {:"num-val", "%x22", [
          {:literal, "%", []},
          {:"hex-val", "x22", [
            {:literal, "x", []},
            {:HEXDIG, "2", [{:digit, "2", []}]},
            {:HEXDIG, "2", [{:digit, "2", []}]}
          ]}
        ]}
      ]},
      {:"c-nl", "\r\n", [
        {:CRLF, "\r\n", [
          {:CR, "\r", []},
          {:LF, "\n", []}
        ]}
      ]}
    ]}) |> Macro.to_string

    assert expected_rulelist == generated_rulelist
  end
end
