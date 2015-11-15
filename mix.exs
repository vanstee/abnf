defmodule Abnf.Mixfile do
  use Mix.Project

  def project do
    [app: :abnf,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     aliases: aliases]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end

  defp aliases do
    ["generate": "abnf.generate",
     "generate.core": &generate_core/1,
     "generate.rfc5234": &generate_rfc5234/1]
  end

  defp generate_core(_) do
    Mix.Task.run("abnf.generate", ["priv/core.abnf", "lib/abnf/core.ex", "Abnf.Core"])
  end

  defp generate_rfc5234(_) do
    Mix.Task.run("abnf.generate", ["priv/rfc5234.abnf", "lib/abnf/rfc5234.ex", "Abnf.Rfc5234"])
  end
end
