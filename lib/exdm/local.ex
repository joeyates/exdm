defmodule Exdm.Local do
  import ReleaseManager.Utils, only: [
    get_last_release: 1,
    rel_dest_path: 1
  ]

  def get_version do
    version = get_last_release(Exdm.application_name)
    {:ok, version}
  end

  def tarball_pathname do
    name = Exdm.application_name
    {:ok, version} = get_version
    path = Path.join([rel_dest_path([name, "releases"]), version, name <> ".tar.gz"])
    {:ok, path}
  end

  def can_transition_from(version) do
    check_transition(handle_relup(:file.consult(relup_path)), version)
  end

  defp relup_path do
    rel_dest_path([Exdm.application_name, "relup"])
  end

  defp handle_relup({:ok, [{to, [{from, _, _}], _}]}) do
    {:ok, to_string(from), to_string(to)}
  end
  defp handle_relup({:error, reason}) do
    {:error, reason}
  end

  defp check_transition({:ok, v1, _v2}, v1) do
    {:ok}
  end
  defp check_transition({:ok, _v1, v2}, v2) do
    {:error, "The currently available release (#{v2}) is already deployed"}
  end
  defp check_transition({:ok, v1, v2}, v3) do
    {:error, "The currently available release updates from version #{v1} to version #{v2}, but the deployed version is #{v3}"}
  end
  defp check_transition({:error, :enoent}, _remote) do
    {:error, "No relup file was found"}
  end
end
