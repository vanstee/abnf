defmodule ABNF.RFC5234 do
  def parse(rule, input) when is_binary(input) do
    parse(rule, String.to_char_list(input))
  end

  def parse(rule, input) do
    parse(rule).(input)
  end

  def parse(:bit) do
    fn input ->
      alternate([
        fn
          '0' ->
            {:bit, "0", []}
          _ ->
            :error
        end,
        fn
          '1' ->
            {:bit, "1", []}
          _ ->
            :error
        end
      ]).(input)
    end
  end

  def parse(:dquote) do
    fn
      '\"' ->
        {:dquote, "\"", []}
      _ ->
        :error
    end
  end

  defp alternate(elements) do
    fn input ->
      alternate(elements, input)
    end
  end

  defp alternate([], input) do
    :error
  end

  defp alternate([element|elements], input) do
    case element.(input) do
      :error ->
        alternate(elements, input)
      result ->
        result
    end
  end
end
