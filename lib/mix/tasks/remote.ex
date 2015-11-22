defmodule Mix.Tasks.Deployment.Remote do
  use Mix.Task

  @shortdoc "Prints the deployed version"

  def run([stage]) do
    {:ok, version} = Exdm.Remote.get_version(String.to_atom(stage))
    IO.puts version
  end
end
