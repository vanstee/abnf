defmodule ABNF do
  alias ABNF.Generator
  alias ABNF.Parser

  def load!(path) do
    path
    |> File.read!
    |> Parser.parse
    |> Generator.generate
  end
end
