defmodule ABNF.RFC5234 do
  import ABNF.Operators

  def parse(rule, input) when is_binary(input) do
    parse(rule, String.to_char_list(input))
  end

  def parse(rule, input) do
    parse(rule).(input)
  end

  defrule :rulelist do
    repeat(1, :infinity,
      alternate([
        parse(:rule),
        concatenate([
          repeat(0, :infinity, parse(:"c-wsp")),
          parse(:"c-nl")
        ])
      ])
    )
  end

  defrule :rule do
    concatenate([
      parse(:rulename),
      parse(:"defined-as"),
      parse(:elements),
      parse(:"c-nl")
    ])
  end

  defrule :rulename do
    concatenate([
      parse(:alpha),
      repeat(0, :infinity,
        alternate([
          parse(:alpha),
          parse(:digit),
          literal('-')
        ])
      )
    ])
  end

  defrule :"defined-as" do
    concatenate([
      repeat(0, :infinity,
        parse(:"c-wsp")
      ),
      alternate([
        literal('='),
        literal('=/')
      ]),
      repeat(0, :infinity,
        parse(:"c-wsp")
      )
    ])
  end

  defrule :elements do
    concatenate([
      parse(:alternation),
      repeat(0, :infinity, parse(:"c-wsp"))
    ])
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

  defrule :comment do
    concatenate([
      literal(';'),
      repeat(0, :infinity,
        alternate([
          parse(:wsp),
          parse(:vchar)
        ])
      ),
      parse(:crlf)
    ])
  end

  defrule :alternation do
    concatenate([
      parse(:concatenation),
      repeat(0, :infinity,
        concatenate([
          repeat(0, :infinity, parse(:"c-wsp")),
          literal('/'),
          repeat(0, :infinity, parse(:"c-wsp")),
          parse(:concatenation)
        ])
      )
    ])
  end

  defrule :concatenation do
    concatenate([
      parse(:repetition),
      repeat(0, :infinity,
        concatenate([
          repeat(1, :infinity, parse(:"c-wsp")),
          parse(:repetition)
        ])
      )
    ])
  end

  defrule :repetition do
    concatenate([
      repeat(0, 1, parse(:repeat)),
      parse(:element)
    ])
  end

  # NOTE: alternating in reverse order
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

  defrule :element do
    alternate([
      parse(:rulename),
      parse(:group),
      parse(:option),
      parse(:"char-val"),
      parse(:"num-val"),
      parse(:"prose-val")
    ])
  end

  defrule :group do
    concatenate([
      literal('('),
      repeat(0, :infinity, parse(:"c-wsp")),
      parse(:alternation),
      repeat(0, :infinity, parse(:"c-wsp")),
      literal(')')
    ])
  end

  defrule :option do
    concatenate([
      literal('['),
      repeat(0, :infinity, parse(:"c-wsp")),
      parse(:alternation),
      repeat(0, :infinity, parse(:"c-wsp")),
      literal(']')
    ])
  end

  defrule :"char-val" do
    concatenate([
      parse(:dquote),
      repeat(0, :infinity, 
        alternate([
          range(0x20, 0x21),
          range(0x23, 0x7E)
        ])
      ),
      parse(:dquote)
    ])
  end

  defrule :"num-val" do
    concatenate([
      literal('%'),
      alternate([
        parse(:"bin-val"),
        parse(:"dec-val"),
        parse(:"hex-val")
      ])
    ])
  end

  defrule :"bin-val" do
    concatenate([
      literal('b'),
      repeat(1, :infinity, parse(:bit)),
      repeat(0, 1,
        alternate([
          repeat(1, :infinity,
            concatenate([
              literal('.'),
              parse(:bit)
            ])
          ),
          concatenate([
            literal('-'),
            repeat(1, :infinity, parse(:bit))
          ])
        ])
      )
    ])
  end

  defrule :"dec-val" do
    concatenate([
      literal('d'),
      repeat(1, :infinity, parse(:digit)),
      repeat(0, 1,
        alternate([
          repeat(1, :infinity,
            concatenate([
              literal('.'),
              parse(:digit)
            ])
          ),
          concatenate([
            literal('-'),
            repeat(1, :infinity, parse(:digit))
          ])
        ])
      )
    ])
  end

  defrule :"hex-val" do
    concatenate([
      literal('x'),
      repeat(1, :infinity, parse(:hexdig)),
      repeat(0, 1,
        alternate([
          repeat(1, :infinity,
            concatenate([
              literal('.'),
              parse(:hexdig)
            ])
          ),
          concatenate([
            literal('-'),
            repeat(1, :infinity, parse(:hexdig))
          ])
        ])
      )
    ])
  end

  defrule :"prose-val" do
    concatenate([
      literal('<'),
      repeat(0, :infinity,
        alternate([
          range(0x20, 0x3D),
          range(0x3F, 0x7E)
        ])
      ),
      literal('>')
    ])
  end

  defrule :alpha do
    alternate([
      range(0x41, 0x5A),
      range(0x61, 0x7A)
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

  defrule :digit do
    range(0x30, 0x39)
  end

  defrule :dquote do
    literal('"')
  end

  defrule :hexdig do
    alternate([
      parse(:digit),
      literal('A'),
      literal('B'),
      literal('C'),
      literal('D'),
      literal('E'),
      literal('F')
    ])
  end

  defrule :htab do
    literal('\t')
  end

  defrule :lf do
    literal('\n')
  end

  defrule :sp do
    literal(' ')
  end

  defrule :vchar do
    range(0x21, 0x7E)
  end

  defrule :wsp do
    alternate([
      parse(:sp),
      parse(:htab)
    ])
  end
end
