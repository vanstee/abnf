defmodule Abnf.Operators do
  defmacro defrule(name, do: block) do
    quote do
      def parse(unquote(name)) do
        fn input ->
          case unquote(block).(input) do
            :error ->
              :error
            children ->
              [{unquote(name), preview(children), children}]
          end
        end
      end
    end
  end

  # TODO: Support multiple chars instead of using this special case
  def literal('=/') do
    fn [?=, ?/|_] ->
      [{:literal, "/=", []}]
      _ ->
        :error
    end
  end

  def literal(element) do
    fn input ->
      literal(element, input)
    end
  end

  def literal([element], input) do
    case input do
      [^element|_] ->
        [{:literal, to_string([element]), []}]
      _ ->
        :error
    end
  end

  def concatenate(elements) do
    fn input ->
      concatenate(elements, [], input)
    end
  end

  defp concatenate([], acc, _input) do
    acc
    |> List.flatten
    |> Enum.reverse
  end

  defp concatenate([element|elements], acc, input) do
    case element.(input) do
      :error ->
        :error
      children ->
        input = advance(children, input)
        children = Enum.reverse(children)
        concatenate(elements, [children|acc], input)
    end
  end

  def alternate(elements) do
    fn input ->
      alternate(elements, [], input)
    end
  end

  defp alternate([], [], _input) do
    :error
  end

  defp alternate([], acc, _input) do
    Enum.max_by(acc, &length/1)
  end

  defp alternate([element|elements], acc, input) do
    case element.(input) do
      :error ->
        alternate(elements, acc, input)
      child ->
        alternate(elements, [child|acc], input)
    end
  end

  def repeat(min, max, element) do
    fn input ->
      repeat(min, max, element, 0, [], input)
    end
  end

  defp repeat(_min, max, _element, max, acc, _input) do
    acc
    |> List.flatten
    |> Enum.reverse
  end

  defp repeat(min, max, element, count, acc, input) do
    case element.(input) do
      :error when count >= min ->
        repeat(min, max, element, max, acc, input)
      :error ->
        :error
      children ->
        input = advance(children, input)
        children = Enum.reverse(children)
        repeat(min, max, element, count + 1, [children|acc], input)
    end
  end

  def range(min, max) do
    fn input ->
      range(min, max, input)
    end
  end

  defp range(min, max, [head|_]) when head >= min and head <= max do
    [{:literal, to_string([head]), []}]
  end

  defp range(_min, _max, _string) do
    :error
  end

  def preview(children) do
    children
    |> Enum.map(fn {_, preview, _} -> preview end)
    |> Enum.join
  end

  def advance(children, input) do
    children
    |> preview
    |> String.to_char_list
    |> string_subtract(input)
  end

  def string_subtract([], string), do: string
  def string_subtract([h|substring], [h|string]) do
    string_subtract(substring, string)
  end
end
