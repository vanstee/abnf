defmodule Abnf.GeneratorTest do
  use ExUnit.Case, async: true
  alias Abnf.Generator

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
