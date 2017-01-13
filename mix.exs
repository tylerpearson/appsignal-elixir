defmodule Mix.Tasks.Compile.Appsignal do
  use Mix.Task

  def run(_args) do
    {_, _} = Code.eval_file("mix_helpers.exs")
    :ok = Mix.Appsignal.Helper.ensure_downloaded
    :ok = Mix.Appsignal.Helper.compile
  end
end

defmodule Appsignal.Mixfile do
  use Mix.Project

  def project do
    [app: :appsignal,
     version: "0.9.2",
     name: "AppSignal",
     description: description(),
     package: package(),
     source_url: "https://github.com/appsignal/appsignal-elixir",
     homepage_url: "https://appsignal.com",
     elixir: "~> 1.0",
     compilers: compilers(Mix.env),
     deps: deps(),
     docs: [logo: "logo.png",
            extras: ["GettingStarted.md", "Phoenix.md", "Roadmap.md"]]
    ]
  end

  defp description do
    "Collects error and performance data from your Elixir applications and sends it to AppSignal"
  end

  defp package do
    %{files: ["lib", "c_src/*.[ch]", "mix.exs", "mix_helpers.exs",
              "*.md", "LICENSE", "Makefile", "agent.json"],
      maintainers: ["Arjan Scherpenisse", "Jeff Kreeftmeijer"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/appsignal/appsignal-elixir"}}
  end

  def application do
    [mod: {Appsignal, []},
     applications: [:logger]]
  end

  defp compilers(:test), do: [:phoenix] ++ compilers(:prod)
  defp compilers(_), do: [:appsignal] ++ Mix.compilers

  defp deps do
    [
      {:poison, "~> 2.1"},
      {:phoenix, "~> 1.2.0"},
      {:decorator, "~> 1.0"},

      {:mock, "~> 0.2.0", only: :test},
      {:ex_doc, "~> 0.12", only: :dev}
    ]
  end
end
