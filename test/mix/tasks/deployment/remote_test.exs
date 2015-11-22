defmodule Mix.Tasks.Deployment.RemoteTest do
  use Exdm.TestCase
  import ExUnit.CaptureIO

  @stage                 "stage"
  @remote_erlang_version "9.9.9"
  @remote_version        "0.2.3"
  @start_erl_content     @remote_erlang_version <> " " <> @remote_version <> "\n"

  test "prints the version running on the remote machine", _context do
    :meck.expect(Exdm.Remote, :get_version, fn _ -> {:ok, @remote_version} end)

    result = capture_io(fn ->
      Mix.Tasks.Deployment.Remote.run([@stage])
    end)

    :meck.unload(Exdm.Remote)

    assert result == @remote_version <> "\n"
  end
end
