defmodule ABNF.Generator do
  def generate({:crlf, preview, _children}) do
    preview
  end

  def generate({:repeat, preview, _children}) do
    preview
  end

  def generate({_rule, preview, []}) do
    preview
  end

  def generate(elements) when is_list(elements) do
    Enum.map(elements, &generate/1)
  end
end
