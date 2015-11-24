defmodule Exdm.Mixfile do
  use Mix.Project

  @version    "0.0.1"

  def project do
    [app: :exdm,
     version: @version,
     elixir: "~> 1.0",
     description: description,
     package: package,
     source_url: "https://github.com/joeyates/exdm",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: Coverex.Task, coveralls: true],
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp description do
    """
    Deploy Elixir applications via mix tasks
    """
  end

  defp package do
    [licenses: ["MIT"],
     maintainers: ["Joe Yates"],
     links: %{github: "https://github.com/joeyates/exdm"}]
  end

  defp deps do
    [
      {:exrm, "~> 0.19.9"},
      {:meck, "~> 0.8.3", only: :test},
      {:coverex, "~> 1.4", only: :test},
      # hackney (coverex dep-dep) doesn't compile under test without this:
      {:cowboy, "1.0.4", only: :test}
    ]
  end
end
