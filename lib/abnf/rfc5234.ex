defmodule ABNF.RFC5234 do
  def parse(rule, input) when is_binary(input) do
    parse(rule, String.to_char_list(input))
  end

  def parse(rule, input) do
    parse(rule).(input)
  end

  def parse(:dquote) do
    fn
      '\"' ->
        {:dquote, "\"", []}
      _ ->
        :error
    end
  end
end
