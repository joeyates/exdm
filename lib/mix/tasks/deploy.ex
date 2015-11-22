defmodule Mix.Tasks.Deployment.Deploy do
  use Mix.Task

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
