defmodule ABNF.RFC5234 do
  def parse(rule, input) when is_binary(input) do
    parse(rule, String.to_char_list(input))
  end

  def parse(rule, input) do
    parse(rule).(input)
  end

  # NOTE: alternate's arg order reversed
  def parse(:repeat) do
    fn input ->
      results = alternate([
        concatenate([
          repeat(0, :infinity, parse(:digit)),
          fn
            [?*|_] ->
              [{:literal, "*", []}]
            _ ->
              :error
          end,
          repeat(0, :infinity, parse(:digit))
        ]),
        repeat(1, :infinity, parse(:digit))
      ]).(input)

      preview = results
      |> Enum.map(fn {_, preview, _} -> preview end)
      |> Enum.join

      [{:repeat, preview, results}]
    end
  end

  def parse(:bit) do
    fn input ->
      alternate([
        fn
          [?0|_] ->
            [{:bit, "0", []}]
          _ ->
            :error
        end,
        fn
          [?1|_] ->
            [{:bit, "1", []}]
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

      [{:crlf, preview, results}]
    end
  end

  def parse(:cr) do
    fn
      [?\r|_] ->
        [{:cr, "\r", []}]
      _ ->
        :error
    end
  end

  def parse(:lf) do
    fn
      [?\n|_] ->
        [{:lf, "\n", []}]
      _ ->
        :error
    end
  end

  def parse(:digit) do
    fn
      [?0|_] ->
        [{:digit, "0", []}]
      [?1|_] ->
        [{:digit, "1", []}]
      [?2|_] ->
        [{:digit, "2", []}]
      [?3|_] ->
        [{:digit, "3", []}]
      [?4|_] ->
        [{:digit, "4", []}]
      [?5|_] ->
        [{:digit, "5", []}]
      [?6|_] ->
        [{:digit, "6", []}]
      [?7|_] ->
        [{:digit, "7", []}]
      [?8|_] ->
        [{:digit, "8", []}]
      [?9|_] ->
        [{:digit, "9", []}]
      _ ->
        :error
    end
  end

  def parse(:dquote) do
    fn
      [?\"|_] ->
        [{:dquote, "\"", []}]
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
      results ->
        preview = results
        |> Enum.map(fn {_, preview, _} -> preview end)
        |> Enum.join

        input = to_string(input)
        ["", input] = String.split(input, preview, parts: 2)
        input = String.to_char_list(input)

        concatenate(elements, [Enum.reverse(results)|acc], input)
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

  defp repeat(min, max, element) do
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
      results ->
        preview = results
        |> Enum.map(fn {_, preview, _} -> preview end)
        |> Enum.join

        input = to_string(input)
        ["", input] = String.split(input, preview, parts: 2)
        input = String.to_char_list(input)

        repeat(min, max, element, count + 1, [Enum.reverse(results)|acc], input)
    end
  end
end
