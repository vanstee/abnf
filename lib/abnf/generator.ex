defmodule ABNF.Generator do
  def generate([{:rulelist, _, _} = rulelist], module) do
    contents = generate(rulelist)

    defmodule module do
      # Import is lexical and eval is not, so the compiler can't see that we're
      # using macros and functions from the imported module below.
      import ABNF.Operators, warn: false

      def parse(rule, input) when is_binary(input) do
        parse(rule, String.to_char_list(input))
      end

      def parse(rule, input) do
        parse(rule).(input)
      end

      Module.eval_quoted(__MODULE__, contents, [], __ENV__)
    end

    module
  end

  def generate({:rulelist, _preview, children}) do
    rules = children
    |> Enum.filter(&match?({:rule, _, _}, &1))
    |> Enum.map(&generate/1)

    rules
  end

  def generate({:rule, _preview, children}) do
    [{:rulename, rulename, _}, _, elements, _] = children

    rulename = String.to_atom(rulename)

    quote do
      defrule unquote(rulename) do
        unquote(generate(elements))
      end
    end
  end

  def generate({:rulename, preview, _children}) do
    rulename = String.to_atom(preview)

    quote do
      parse(unquote(rulename))
    end
  end

  def generate({:elements, _preview, children}) do
    [alternation|_] = children

    quote do
      unquote(generate(alternation))
    end
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
    children = children
    |> Enum.filter(&(elem(&1, 0) == :repetition))
    |> Enum.map(&generate/1)

    quote do
      concatenate([
        unquote_splicing(children)
      ])
    end
  end

  def generate({:repetition, _preview, children}) do
    case children do
      [repeat, element] ->
        case repeat do
          {:repeat, _, []} ->
            quote do
              repeat(0, :infinity, unquote(generate(element)))
            end
          {:repeat, _, children} ->
            index = Enum.find_index(children, &match?({:literal, "*", _}, &1))
            {min, [_|max]} = Enum.split(children, index)

            min = case min do
              [] ->
                0
              _ ->
                min
                |> Enum.map(fn {_, preview, _} -> preview end)
                |> Enum.join
                |> String.to_integer(16)
            end

            max = case max do
              [] ->
                :infinity
              _ ->
                max
                |> Enum.map(fn {_, preview, _} -> preview end)
                |> Enum.join
                |> String.to_integer(16)
            end

            quote do
              repeat(unquote(min), unquote(max), unquote(generate(element)))
            end
        end
      [element] ->
        generate(element)
    end
  end

  def generate({:element, _preview, children}) do
    generate(children)
  end

  def generate({:group, _preview, children}) do
    [alternation] = children
    |> Enum.filter(&(elem(&1, 0) == :alternation))
    |> Enum.map(&generate/1)

    alternation
  end

  def generate({:option, _preview, children}) do
    [alternation] = children
    |> Enum.filter(&(elem(&1, 0) == :alternation))
    |> Enum.map(&generate/1)

    quote do
      repeat(0, 1, unquote(alternation))
    end
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
    generate(hex_val)
  end

  def generate({:"hex-val", _preview, children}) do
    [_|digits] = children

    cond do
      Enum.any?(digits, &match?({:literal, "-", _}, &1)) ->
        index = Enum.find_index(digits, &match?({:literal, "-", _}, &1))
        {min, [_|max]} = Enum.split(digits, index)

        min = min
        |> Enum.map(fn {_, preview, _} -> preview end)
        |> Enum.join
        |> String.to_integer(16)

        max = max
        |> Enum.map(fn {_, preview, _} -> preview end)
        |> Enum.join
        |> String.to_integer(16)

        quote do
          range(unquote(min), unquote(max))
        end
      true ->
        integer = digits
        |> Enum.map(fn {_, preview, _} -> preview end)
        |> Enum.join
        |> String.to_integer(16)

        quote do
          literal([unquote(integer)])
        end
    end
  end

  def generate({:"c-nl", _preview, _children}) do
    nil
  end

  def generate({:"c-wsp", _preview, _children}) do
    nil
  end

  def generate({:CRLF, preview, _children}) do
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
