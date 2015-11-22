defmodule Mix.Tasks.Deployment.Local do
  use Mix.Task

  @shortdoc "Prints the latest version built on local machine"

  def run(_args) do
    {:ok, version} = Exdm.Local.get_version
    IO.puts version
  end
end
