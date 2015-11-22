defmodule Mix.Tasks.Deployment.LocalTest do
  use Exdm.TestCase
  import ExUnit.CaptureIO

  @local_version        "0.2.3"

  setup do
    on_exit fn ->
      :meck.unload(Exdm.Local)
    end
  end

  test "prints the version running on the local machine", _context do
    :meck.expect(Exdm.Local, :get_version, fn -> {:ok, @local_version} end)

    result = capture_io(fn ->
      Mix.Tasks.Deployment.Local.run([])
    end)

    assert result == @local_version <> "\n"
  end
end
