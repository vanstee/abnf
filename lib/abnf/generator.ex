defmodule ABNF.Generator do
  def generate({:bit, preview, []}) do
    preview
  end

  def generate({:dquote, preview, []}) do
    preview
  end
end
