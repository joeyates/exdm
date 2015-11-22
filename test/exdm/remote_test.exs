defmodule Exdm.RemoteTest do
  use Exdm.TestCase

  @stage                 :stage
  @config                "config"
  @application_path      "/foo"
  @user_and_host         "me@example.com"
  @remote_erlang_version "9.9.9"
  @remote_version        "0.2.3"
  @start_erl_content     @remote_erlang_version <> " " <> @remote_version <> "\n"

  test "get_version/1 returns the version running on the remote machine", _context do
    :meck.expect(Exdm.Config, :load!, fn _stage -> @config end)
    :meck.expect(Exdm.Config, :application_path!, fn _ -> @application_path end)
    :meck.expect(Exdm.Config, :user_and_host!, fn _config -> @user_and_host end)
    :meck.expect(Exdm.Connection, :execute, fn _stage, _ssh_params -> {:ok, @start_erl_content} end)

    {:ok, version} = Exdm.Remote.get_version(@stage)

    ssh_params = ["cat", @application_path <> "/releases/start_erl.data"]
    assert :meck.capture(1, Exdm.Connection, :execute, 2, 1) == @stage
    assert :meck.capture(1, Exdm.Connection, :execute, 2, 2) == ssh_params

    :meck.unload(Exdm.Config)
    :meck.unload(Exdm.Connection)

    assert version == @remote_version
  end

  # TODO: test missing config for stage
end
