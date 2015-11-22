defmodule Exdm.ConnectionTest do
  use Exdm.TestCase

  @stage                 :stage
  @config                "config"
  @params                ["foo"]
  @user_and_host         "user@example.com"
  @output                "output"
  @local_pathname        "/local/path/file.tgz"
  @remote_path           "/remote/path"

  test "execute/2 runs a command via SSH" do
    :meck.expect(Exdm.Config, :load!, fn _ -> @config end)
    :meck.expect(Exdm.Config, :user_and_host, fn _ -> {:ok, @user_and_host} end)
    :meck.expect(System, :cmd, fn _, _ -> {@output, 0} end)

    {:ok, result} = Exdm.Connection.execute(@stage, @params)

    assert :meck.capture(1, System, :cmd, 2, 1) == "ssh"
    assert :meck.capture(1, System, :cmd, 2, 2) == [@user_and_host, "bash -lc \"foo\""]
    assert result == @output

    :meck.unload(Exdm.Config)
    :meck.unload(System)
  end

  test "upload/3 uploads a file" do
    :meck.expect(Exdm.Config, :load!, fn _ -> @config end)
    :meck.expect(Exdm.Config, :user_and_host, fn _ -> {:ok, @user_and_host} end)
    :meck.expect(System, :cmd, fn _, _ -> {@output, 0} end)

    {:ok} = Exdm.Connection.upload(@stage, @local_pathname, @remote_path)

    assert :meck.capture(1, System, :cmd, 2, 1) == "ssh"
    assert :meck.capture(1, System, :cmd, 2, 2) == [@user_and_host, "mkdir", "-p", @remote_path]
    assert :meck.capture(2, System, :cmd, 2, 1) == "scp"
    assert :meck.capture(2, System, :cmd, 2, 2) == [@local_pathname, @user_and_host <> ":" <> @remote_path]

    :meck.unload(Exdm.Config)
    :meck.unload(System)
  end
end
