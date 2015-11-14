defmodule ABNF.GeneratorTest do
  use ExUnit.Case
  alias ABNF.Generator

  test "generating a dquote" do
    assert "\"" = Generator.generate({:dquote, "\"", []})
  end

  test "generating a bit" do
    assert "0" = Generator.generate({:bit, "0", []})
    assert "1" = Generator.generate({:bit, "1", []})
  end

  test "generating a crlf" do
    assert "\r\n" = Generator.generate({:crlf, "\r\n", [
      {:cr, "\r", []},
      {:lf, "\n", []},
    ]})
  end

  test "generating a repeat" do
    assert "1*23" = Generator.generate({:repeat, "1*23", [
      {:digit, "1", []},
      {:literal, "*", []},
      {:digit, "2", []},
      {:digit, "3", []}
    ]})
  end

  test "generating a rulelist" do
    expected_rulelist = """
    defrule(:DQUOTE) do
      literal('"')
    end
    """ |> String.rstrip

    generated_rulelist = Generator.generate({:rulelist, "DQUOTE = %x22\r\n", [
      {:rule, "DQUOTE = %x22\r\n", [
        {:rulename, "DQUOTE", [
          {:alpha, "D", []},
          {:alpha, "Q", []},
          {:alpha, "U", []},
          {:alpha, "O", []},
          {:alpha, "T", []},
          {:alpha, "E", []}
        ]},
        {:"defined-as", " = ", [
          {:"c-wsp", " ", [
            {:wsp, " ", [
              {:sp, " ", []}
            ]}
          ]},
          {:literal, "=", []},
          {:"c-wsp", " ", [
            {:wsp, " ", [
              {:sp, " ", []}
            ]}
          ]}
        ]},
        {:elements, "%x22", [
          {:"num-val", "%x22", [
            {:literal, "%", []},
            {:"hex-val", "x22", [
              {:literal, "x", []},
              {:hexdig, "2", [{:digit, "2", []}]},
              {:hexdig, "2", [{:digit, "2", []}]}
            ]}
          ]}
        ]},
        {:"c-nl", "\r\n", [
          {:crlf, "\r\n", [
            {:cr, "\r", []},
            {:lf, "\n", []}
          ]}
        ]}
      ]}
    ]}) |> Macro.to_string

    assert expected_rulelist == generated_rulelist
  end
end
