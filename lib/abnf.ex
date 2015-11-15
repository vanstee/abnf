defmodule ABNF do
  alias ABNF.Generator
  alias ABNF.Parser

  def load!(path) do
    module = path
    |> Path.basename(".abnf")
    |> String.capitalize
    |> String.to_atom

    path
    |> File.read!
    |> Parser.parse
    |> Generator.generate(module)
  end
end
