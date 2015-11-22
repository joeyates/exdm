defmodule ExdmTest do
  use Exdm.TestCase

  @stage               :stage
  @config              "config"
  @version             "0.1.2"
  @local_tarball_path  "/local/path/release/" <> @version <> ".tar.gz"
  @application_path    "/remote/path"
  @releases_path       @application_path <> "/releases"
  @output              "output"

  test "deploy/1 copies the tarball to the remote host" do
    :meck.expect(Exdm.Config, :load!, fn _ -> @config end)
    :meck.expect(Exdm.Config, :application_path!, fn _ -> @application_path end)
    :meck.expect(Exdm.Local, :tarball_pathname, fn -> {:ok, @local_tarball_path} end)
    :meck.expect(Exdm.Local, :get_version, fn -> {:ok, @version} end)
    :meck.expect(Exdm.Remote, :releases_path!, fn _ -> @releases_path end)
    :meck.expect(Exdm.Connection, :upload, fn _, _, _ -> {:ok} end)
    :meck.expect(Exdm.Connection, :execute, fn _, _ -> {:ok, @output} end)

    Exdm.deploy(@stage)

    :meck.unload(Exdm.Config)
    :meck.unload(Exdm.Local)
    :meck.unload(Exdm.Remote)

    assert :meck.capture(1, Exdm.Connection, :upload, 3, 1) == @stage
    assert :meck.capture(1, Exdm.Connection, :upload, 3, 2) == @local_tarball_path
    release_path = @releases_path <> "/" <> @version
    assert :meck.capture(1, Exdm.Connection, :upload, 3, 3) == release_path
    assert :meck.capture(1, Exdm.Connection, :execute, 2, 1) == @stage
    boot_script_path = @application_path <> "/bin/exdm"
    assert :meck.capture(1, Exdm.Connection, :execute, 2, 2) == [boot_script_path, "upgrade", @version]

    :meck.unload(Exdm.Connection)
  end

  test ".deploy performs the upgrade" do
  end
end
