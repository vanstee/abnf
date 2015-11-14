defmodule ABNF.Generator do
  def generate({:rulelist, preview, children}) do
    quote do
      unquote_splicing(Enum.map(children, &generate/1))
    end
  end

  def generate({:rule, _preview, children}) do
    [rulename, _, elements, _] = children

    quote do
      defrule unquote(generate(rulename)) do
        unquote(generate(elements))
      end
    end
  end

  def generate({:rulename, preview, _children}) do
    String.to_atom(preview)
  end

  def generate({:elements, _preview, children}) do
    generate(children)
  end

  def generate({:"num-val", _preview, children}) do
    [_, hex_val] = children

    quote do
      literal(unquote(generate(hex_val)))
    end
  end

  def generate({:"hex-val", _preview, children}) do
    [_|digits] = children

    integer = digits
    |> Enum.map(fn {_, preview, _} -> preview end)
    |> Enum.join
    |> String.to_integer(16)

    quote do
      [unquote(integer)]
    end
  end

  def generate({:crlf, preview, _children}) do
    preview
  end

  def generate({:repeat, preview, _children}) do
    preview
  end

  def generate({_rule, preview, []}) do
    preview
  end

  def generate([element]) do
    generate(element)
  end
end
