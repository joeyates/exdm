defmodule Exdm do
  def deploy(stage) do
    config = Exdm.Config.load!(stage)
    Exdm.Connection.upload(stage, release_tarball, remote_release_path!(config))
    boot_script_path = Exdm.Remote.boot_script_path!(config)
    Exdm.Connection.execute(stage, [boot_script_path, "upgrade", version])
  end

  def application_name do
    Mix.Project.config[:app] |> Atom.to_string
  end

  defp release_tarball do
    {:ok, path} = Exdm.Local.tarball_pathname
    path
  end

  defp remote_release_path!(config) do
    releases_path = Exdm.Remote.releases_path!(config)
    releases_path <> "/" <> version
  end

  defp version do
    {:ok, version} = Exdm.Local.get_version
    version
  end
end
