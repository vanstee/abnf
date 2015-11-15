defmodule(Abnf.Rfc5234) do
  import(Abnf.Operators, warn: false)
  def(parse(rule, input) when is_binary(input)) do
    parse(rule, String.to_char_list(input))
  end
  def(parse(rule, input)) do
    parse(rule).(input)
  end
  defrule(:ALPHA) do
    alternate([range(65, 90), range(97, 122)])
  end
  defrule(:BIT) do
    alternate([literal('0'), literal('1')])
  end
  defrule(:CHAR) do
    range(1, 127)
  end
  defrule(:CR) do
    literal('\r')
  end
  defrule(:CRLF) do
    concatenate([parse(:CR), parse(:LF)])
  end
  defrule(:CTL) do
    alternate([range(0, 31), literal([127])])
  end
  defrule(:DIGIT) do
    range(48, 57)
  end
  defrule(:DQUOTE) do
    literal('"')
  end
  defrule(:HEXDIG) do
    alternate([parse(:DIGIT), literal('A'), literal('B'), literal('C'), literal('D'), literal('E'), literal('F')])
  end
  defrule(:HTAB) do
    literal('\t')
  end
  defrule(:LF) do
    literal('\n')
  end
  defrule(:LWSP) do
    repeat(0, :infinity, alternate([parse(:WSP), concatenate([parse(:CRLF), parse(:WSP)])]))
  end
  defrule(:OCTET) do
    range(0, 255)
  end
  defrule(:SP) do
    literal(' ')
  end
  defrule(:VCHAR) do
    range(33, 126)
  end
  defrule(:WSP) do
    alternate([parse(:SP), parse(:HTAB)])
  end
  defrule(:rulelist) do
    repeat(1, :infinity, alternate([parse(:rule), concatenate([repeat(0, :infinity, parse(:"c-wsp")), parse(:"c-nl")])]))
  end
  defrule(:rule) do
    concatenate([parse(:rulename), parse(:"defined-as"), parse(:elements), parse(:"c-nl")])
  end
  defrule(:rulename) do
    concatenate([parse(:ALPHA), repeat(0, :infinity, alternate([parse(:ALPHA), parse(:DIGIT), literal('-')]))])
  end
  defrule(:"defined-as") do
    concatenate([repeat(0, :infinity, parse(:"c-wsp")), alternate([literal('='), literal('=/')]), repeat(0, :infinity, parse(:"c-wsp"))])
  end
  defrule(:elements) do
    concatenate([parse(:alternation), repeat(0, :infinity, parse(:"c-wsp"))])
  end
  defrule(:"c-wsp") do
    alternate([parse(:WSP), concatenate([parse(:"c-nl"), parse(:WSP)])])
  end
  defrule(:"c-nl") do
    alternate([parse(:comment), parse(:CRLF)])
  end
  defrule(:comment) do
    concatenate([literal(';'), repeat(0, :infinity, alternate([parse(:WSP), parse(:VCHAR)])), parse(:CRLF)])
  end
  defrule(:alternation) do
    concatenate([parse(:concatenation), repeat(0, :infinity, concatenate([repeat(0, :infinity, parse(:"c-wsp")), literal('/'), repeat(0, :infinity, parse(:"c-wsp")), parse(:concatenation)]))])
  end
  defrule(:concatenation) do
    concatenate([parse(:repetition), repeat(0, :infinity, concatenate([repeat(1, :infinity, parse(:"c-wsp")), parse(:repetition)]))])
  end
  defrule(:repetition) do
    concatenate([repeat(0, 1, parse(:repeat)), parse(:element)])
  end
  defrule(:repeat) do
    alternate([repeat(1, :infinity, parse(:DIGIT)), concatenate([repeat(0, :infinity, parse(:DIGIT)), literal('*'), repeat(0, :infinity, parse(:DIGIT))])])
  end
  defrule(:element) do
    alternate([parse(:rulename), parse(:group), parse(:option), parse(:"char-val"), parse(:"num-val"), parse(:"prose-val")])
  end
  defrule(:group) do
    concatenate([literal('('), repeat(0, :infinity, parse(:"c-wsp")), parse(:alternation), repeat(0, :infinity, parse(:"c-wsp")), literal(')')])
  end
  defrule(:option) do
    concatenate([literal('['), repeat(0, :infinity, parse(:"c-wsp")), parse(:alternation), repeat(0, :infinity, parse(:"c-wsp")), literal(']')])
  end
  defrule(:"char-val") do
    concatenate([parse(:DQUOTE), repeat(0, :infinity, alternate([range(32, 33), range(35, 126)])), parse(:DQUOTE)])
  end
  defrule(:"num-val") do
    concatenate([literal('%'), alternate([parse(:"bin-val"), parse(:"dec-val"), parse(:"hex-val")])])
  end
  defrule(:"bin-val") do
    concatenate([literal('b'), repeat(1, :infinity, parse(:BIT)), repeat(0, 1, alternate([repeat(1, :infinity, concatenate([literal('.'), repeat(1, :infinity, parse(:BIT))])), concatenate([literal('-'), repeat(1, :infinity, parse(:BIT))])]))])
  end
  defrule(:"dec-val") do
    concatenate([literal('d'), repeat(1, :infinity, parse(:DIGIT)), repeat(0, 1, alternate([repeat(1, :infinity, concatenate([literal('.'), repeat(1, :infinity, parse(:DIGIT))])), concatenate([literal('-'), repeat(1, :infinity, parse(:DIGIT))])]))])
  end
  defrule(:"hex-val") do
    concatenate([literal('x'), repeat(1, :infinity, parse(:HEXDIG)), repeat(0, 1, alternate([repeat(1, :infinity, concatenate([literal('.'), repeat(1, :infinity, parse(:HEXDIG))])), concatenate([literal('-'), repeat(1, :infinity, parse(:HEXDIG))])]))])
  end
  defrule(:"prose-val") do
    concatenate([literal('<'), repeat(0, :infinity, alternate([range(32, 61), range(63, 126)])), literal('>')])
  end
end
