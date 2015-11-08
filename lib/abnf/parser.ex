defmodule ABNF.Parser do
  alias ABNF.RFC5234

  def parse(input) do
    RFC5234.parse(:rulelist, input)
  end
end
