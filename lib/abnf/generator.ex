defmodule Abnf.Generator do
  def generate([{:rulelist, _preview, _children} = rulelist], module) do
    parsers = [parse_helpers, generate(rulelist), forwarder(module)]
    |> Enum.reject(&is_nil/1)
    |> List.flatten

    quote do
      defmodule unquote(module) do
        import Abnf.Operators

        unquote_splicing(parsers)
      end
    end
  end

  def generate({:rulelist, _preview, children}) do
    children
    |> Enum.filter(&match?({:rule, _, _}, &1))
    |> Enum.map(&generate/1)
  end

  def generate({:rule, _preview, [{_, rulename, _}, _, elements, _]}) do
    rulename = String.to_atom(rulename)
    elements = generate(elements)

    quote do
      defrule unquote(rulename) do
        unquote(elements)
      end
    end
  end

  def generate({:rulename, preview, _children}) do
    rulename = String.to_atom(preview)

    quote do
      parse(unquote(rulename))
    end
  end

  def generate({:elements, _preview, [alternation|_]}) do
    generate(alternation)
  end

  def generate({:alternation, _preview, [concatenation]}) do
    generate(concatenation)
  end

  def generate({:alternation, _preview, children}) do
    children = children
    |> Enum.filter(&match?({:concatenation, _, _}, &1))
    |> Enum.map(&generate/1)

    quote do
      alternate([unquote_splicing(children)])
    end
  end

  def generate({:concatenation, _preview, [repetition]}) do
    generate(repetition)
  end

  def generate({:concatenation, _preview, children}) do
    children = children
    |> Enum.filter(&match?({:repetition, _, _}, &1))
    |> Enum.map(&generate/1)

    quote do
      concatenate([unquote_splicing(children)])
    end
  end

  def generate({:repetition, _preview, [element]}) do
    generate(element)
  end

  def generate({:repetition, _, [{:repeat, _, children}, element]}) do
    {min, max} = case Enum.chunk_by(children, &match?({:literal, "*", []}, &1)) do
      [[{:literal, "*", []}]] ->
        {0, :infinity}
      [min] ->
        {generate_digits(min), :infinity}
      [min, [{:literal, "*", []}]] ->
        {generate_digits(min), :infinity}
      [[{:literal, "*", []}], max] ->
        {0, max}
      [min, [{:literal, "*", []}], max] ->
        {min, max}
    end

    element = generate(element)

    quote do
      repeat(unquote(min), unquote(max), unquote(element))
    end
  end

  def generate({:element, _preview, [child]}) do
    generate(child)
  end

  def generate({:group, _preview, children}) do
    alternation = Enum.find(children, &match?({:alternation, _, _}, &1))

    generate(alternation)
  end

  def generate({:option, _preview, children}) do
    alternation = Enum.find(children, &match?({:alternation, _, _}, &1))

    quote do
      repeat(0, 1, unquote(generate(alternation)))
    end
  end

  def generate({:"char-val", _preview, children}) do
    char_val = children
    |> Enum.filter(&match?({:literal, _, []}, &1))
    |> Enum.map_join(&elem(&1, 1))
    |> String.to_char_list

    quote do
      literal(unquote(char_val))
    end
  end

  def generate({:"num-val", _preview, [_, child]}) do
    generate(child)
  end

  def generate({rule, _preview, [_|children]}) when rule in [:"bin-val", :"dec-val", :"hex-val"] do
    case Enum.chunk_by(children, &match?({:literal, "-", []}, &1)) do
      [digits] ->
        integer = generate_digits(digits, rule)

        quote do
          literal([unquote(integer)])
        end
      [min, _, max] ->
        min = generate_digits(min, rule)
        max = generate_digits(max, rule)

        quote do
          range(unquote(min), unquote(max))
        end
    end
  end

  defp parse_helpers do
    [quote do
       def parse(rule, input) when is_binary(input) do
         parse(rule, String.to_char_list(input))
       end
     end,
     quote do
       def parse(rule, input) do
         parse(rule).(input)
       end
     end]
  end

  defp forwarder(module) do
    case module do
      Abnf.Core ->
        nil
      _ ->
        quote do
          def parse(rule) do
            Abnf.Core.parse(rule)
          end
        end
    end
  end

  defp generate_digits(digits) do
    generate_digits(digits, :"dec-val")
  end

  defp generate_digits(digits, type) do
    base = case type do
      :"bin-val" ->  2
      :"dec-val" -> 10
      :"hex-val" -> 16
    end

    digits
    |> Enum.map_join(&elem(&1, 1))
    |> String.to_integer(base)
  end
end
