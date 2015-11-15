defmodule Mix.Tasks.Abnf.Generate do
  use Mix.Task

  def run([src, dest]) do
    src
    |> Abnf.compile
    |> write_code(dest)
  end

  def run([src, dest, name]) do
    module_name = ensure_module_name(name)

    src
    |> Abnf.compile(module_name)
    |> write_code(dest)
  end

  defp write_code(quoted_module, dest) do
    module_code = Macro.to_string(quoted_module)
    File.write!(dest, module_code)
    IO.puts("Generated #{dest}")
  end

  defp ensure_module_name(name) when is_atom(name) do
    name
  end

  defp ensure_module_name(name) when is_binary(name) do
    module_name = cond do
      String.starts_with?(name, "Elixir.") ->
        name
      true ->
        Enum.join(["Elixir", name], ".")
    end

    String.to_atom(module_name)
  end
end
