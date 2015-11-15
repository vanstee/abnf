defmodule Abnf do
  alias Abnf.Generator
  alias Abnf.Parser

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
