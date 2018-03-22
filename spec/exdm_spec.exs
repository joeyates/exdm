defmodule ExdmSpec do
  use ESpec

  context "deploy/1" do
    let :stage, do: :stage
    let :config, do: "config"
    let :application_path, do: "/remote/path"
    let :boot_script_path, do: application_path() <> "/bin/exdm"
    let :releases_path, do: application_path() <> "/releases"
    let :version, do: "0.1.2"
    let :release_path, do: releases_path() <> "/" <> version()
    let :local_tarball_path, do: "/local/path/release/" <> version() <> ".tar.gz"
    let :output, do: "output"

    before do
      :meck.expect(Exdm.Config, :load!, fn _ -> config() end)
      :meck.expect(Exdm.Config, :application_path!, fn _ -> application_path() end)
      :meck.expect(Exdm.Local, :tarball_pathname, fn -> {:ok, local_tarball_path()} end)
      :meck.expect(Exdm.Local, :get_version, fn -> {:ok, version()} end)
      :meck.expect(Exdm.Remote, :releases_path!, fn _ -> releases_path() end)
      :meck.expect(Exdm.Connection, :upload, fn _, _, _ -> {:ok} end)
      :meck.expect(Exdm.Connection, :execute, fn _, _ -> {:ok, output()} end)

      Exdm.deploy(stage())
    end

    finally do
      :meck.unload(Exdm.Connection)
      :meck.unload(Exdm.Config)
      :meck.unload(Exdm.Local)
      :meck.unload(Exdm.Remote)
    end

    it "copies the tarball to the remote host" do
      #expect Exdm.Connection |> to accepted :upload, [
      #  stage, local_tarball_path, release_path
      #]
    end

    it "performs the upgrade" do
      #expect Exdm.Connection |> to accepted :execute, [
      #  stage, [boot_script_path, "upgrade", version]
      #]
    end
  end
end
