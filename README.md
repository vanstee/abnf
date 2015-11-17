# Abnf

[![Build Status](https://travis-ci.org/vanstee/abnf.svg?branch=master)](https://travis-ci.org/vanstee/abnf)

## Example

```elixir
iex(1)> parser = Abnf.load("priv/rfc5234.abnf")
Rfc5234
iex(2)> parser.parse(:rule, "DQUOTE = %x22\r\n")
[{:rule, "DQUOTE = %x22\r\n",
  [{:rulename, "DQUOTE",
    [{:ALPHA, "D", [{:literal, "D", []}]}, {:ALPHA, "Q", [{:literal, "Q", []}]},
     {:ALPHA, "U", [{:literal, "U", []}]}, {:ALPHA, "O", [{:literal, "O", []}]},
     {:ALPHA, "T", [{:literal, "T", []}]},
     {:ALPHA, "E", [{:literal, "E", []}]}]},
   {:"defined-as", " = ",
    [{:"c-wsp", " ", [{:WSP, " ", [{:SP, " ", [{:literal, " ", []}]}]}]},
     {:literal, "=", []},
     {:"c-wsp", " ", [{:WSP, " ", [{:SP, " ", [{:literal, " ", []}]}]}]}]},
   {:elements, "%x22",
    [{:alternation, "%x22",
      [{:concatenation, "%x22",
        [{:repetition, "%x22",
          [{:element, "%x22",
            [{:"num-val", "%x22",
              [{:literal, "%", []},
               {:"hex-val", "x22",
                [{:literal, "x", []},
                 {:HEXDIG, "2", [{:DIGIT, "2", [{:literal, "2", []}]}]},
                 {:HEXDIG, "2",
                  [{:DIGIT, "2", [{:literal, "2", []}]}]}]}]}]}]}]}]}]},
   {:"c-nl", "\r\n",
    [{:CRLF, "\r\n",
      [{:CR, "\r", [{:literal, "\r", []}]},
       {:LF, "\n", [{:literal, "\n", []}]}]}]}]}]
```

## TODO

- [x] Build minimal parser
- [x] Build minimal generator
- [x] Use self-hosted parser
- [x] Parse rfc2822
- [x] Clean up generator
- [ ] Improve test coverage
- [ ] Log error messages during parsing
- [ ] Improve UX of parsing for specific rules

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add abnf to your list of dependencies in `mix.exs`:

        def deps do
          [{:abnf, "~> 0.0.1"}]
        end

  2. Ensure abnf is started before your application:

        def application do
          [applications: [:abnf]]
        end
