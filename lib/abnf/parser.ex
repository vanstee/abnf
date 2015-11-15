defmodule Abnf.Parser do
  alias Abnf.Rfc5234

  def parse(input) do
    Rfc5234.parse(:rulelist, input)
  end
end
