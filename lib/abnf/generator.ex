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

  def generate({:alternation, _preview, [child]}) do
    quote do
      unquote(generate(child))
    end
  end

  def generate({:alternation, _preview, children}) do
    children = children
    |> Enum.filter(&(elem(&1, 0) == :concatenation))
    |> Enum.map(&generate/1)

    quote do
      alternate([
        unquote_splicing(children)
      ])
    end
  end

  def generate({:concatenation, _preview, [child]}) do
    quote do
      unquote(generate(child))
    end
  end

  def generate({:concatenation, _preview, children}) do
    quote do
      concatenate([
        unquote_splicing(Enum.map(children, &generate/1))
      ])
    end
  end

  # TODO: Use repeat
  def generate({:repetition, _preview, children}) do
    generate(children)
  end

  def generate({:element, _preview, children}) do
    generate(children)
  end

  def generate({:"char-val", _preview, children}) do
    char_val = children
    |> Enum.map(&generate/1)
    |> Enum.join
    |> String.strip(?")
    |> String.to_char_list

    quote do
      literal(unquote(char_val))
    end
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

  def generate({:"c-wsp", preview, _children}) do
    nil
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
