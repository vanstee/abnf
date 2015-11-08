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
          [?0|_] ->
            {:bit, "0", []}
          _ ->
            :error
        end,
        fn
          [?1|_] ->
            {:bit, "1", []}
          _ ->
            :error
        end
      ]).(input)
    end
  end

  def parse(:crlf) do
    fn input ->
      results = concatenate([
        parse(:cr),
        parse(:lf)
      ]).(input)

      preview = results
      |> Enum.map(fn {_, preview, _} -> preview end)
      |> Enum.join

      {:crlf, preview, results}
    end
  end

  def parse(:cr) do
    fn
      [?\r|_] ->
        {:cr, "\r", []}
      _ ->
        :error
    end
  end

  def parse(:lf) do
    fn
      [?\n|_] ->
        {:lf, "\n", []}
      _ ->
        :error
    end
  end

  def parse(:dquote) do
    fn
      [?\"|_] ->
        {:dquote, "\"", []}
      _ ->
        :error
    end
  end

  defp concatenate(elements) do
    fn input ->
      concatenate(elements, [], input)
    end
  end

  defp concatenate([], acc, '') do
    acc
    |> List.flatten
    |> Enum.reverse
  end

  defp concatenate([element|elements], acc, input) do
    case element.(input) do
      :error ->
        :error
      {_, preview, _} = result ->
        input = to_string(input)
        ["", input] = String.split(input, preview, parts: 2)
        input = String.to_char_list(input)

        concatenate(elements, [result|acc], input)
    end
  end

  defp alternate(elements) do
    fn input ->
      alternate(elements, input)
    end
  end

  defp alternate([], _input) do
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
