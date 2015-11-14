defmodule ABNF.RFC5234 do
  import ABNF.Operators

  def parse(rule, input) when is_binary(input) do
    parse(rule, String.to_char_list(input))
  end

  def parse(rule, input) do
    parse(rule).(input)
  end

  defrule :"c-wsp" do
    alternate([
      parse(:wsp),
      concatenate([
        parse(:"c-nl"),
        parse(:wsp)
      ])
    ])
  end

  defrule :"c-nl" do
    alternate([
      parse(:comment),
      parse(:crlf)
    ])
  end

  # NOTE: alternate's arg order reversed
  defrule :repeat do
    alternate([
      concatenate([
        repeat(1, :infinity, parse(:digit)),
        literal('*'),
        repeat(0, :infinity, parse(:digit))
      ]),
      repeat(1, :infinity, parse(:digit))
    ])
  end

  defrule :bit do
    alternate([
      literal('0'),
      literal('1')
    ])
  end

  defrule :crlf do
    concatenate([
      parse(:cr),
      parse(:lf)
    ])
  end

  defrule :cr do
    literal('\r')
  end

  defrule :lf do
    literal('\n')
  end

  defrule :digit do
    alternate([
      literal('0'),
      literal('1'),
      literal('2'),
      literal('3'),
      literal('4'),
      literal('5'),
      literal('6'),
      literal('7'),
      literal('8'),
      literal('9')
    ])
  end

  defrule :dquote do
    literal('"')
  end
end
