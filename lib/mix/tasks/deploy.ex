defmodule Mix.Tasks.Deployment.Deploy do
  use Mix.Task

  @shortdoc "Deploys to the given stage"

  @moduledoc """
  Deploys to a stage.

      mix deployment.deploy production

  The argument is the name of a stage.

  Before running, it checks the following:
  * is the application deployed to the remote host?
  * is a release available of the current version of the application?
  * if so, is it possible to upgrade from the local release from the currently
    deployed one?
  """

  def run([stage]) do
    stage = String.to_atom(stage)
    {:ok, remote_version} = Exdm.Remote.get_version(stage)
    handle_can_transition_from(stage, Exdm.Local.can_transition_from(remote_version))
  end

  defp handle_can_transition_from(stage, {:ok}) do
    Exdm.deploy(stage)
    {:ok}
  end
  defp handle_can_transition_from(_stage, {:error, reason}) do
    {:error, reason}
  end
end
