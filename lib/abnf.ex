defmodule Abnf do
  alias Abnf.Generator
  alias Abnf.Parser

  def load(path) do
    {module, []} = path
    |> compile
    |> Code.eval_quoted

    {:module, module_name, _, _} = module
    module_name
  end

  def compile(path) do
    compile(path, module_name(path))
  end

  def compile(path, name) do
    path
    |> File.read!
    |> Parser.parse
    |> Generator.generate(name)
  end

  def module_name(path) do
    name = path
    |> Path.basename(".abnf")
    |> String.capitalize

    Module.concat("Elixir", name)
  end
end
