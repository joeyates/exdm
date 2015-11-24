defmodule Mix.Tasks.Deployment.IsRunningTest do
  use Exdm.TestCase
  import ExUnit.CaptureIO

  @stage                 "stage"
  @remote_erlang_version "9.9.9"
  @remote_version        "0.2.3"
  @start_erl_content     @remote_erlang_version <> " " <> @remote_version <> "\n"

  test "prints 'yes' if the application is running", _context do
    :meck.expect(Exdm.Remote, :is_running?, fn _ -> {:ok, :yes} end)

    result = capture_io(fn ->
      Mix.Tasks.Deployment.IsRunning.run([@stage])
    end)

    :meck.unload(Exdm.Remote)

    assert result == "yes\n"
  end


  test "prints 'no' if the application is not running", _context do
    :meck.expect(Exdm.Remote, :is_running?, fn _ -> {:ok, :no} end)

    result = capture_io(fn ->
      Mix.Tasks.Deployment.IsRunning.run([@stage])
    end)

    :meck.unload(Exdm.Remote)

    assert result == "no\n"
  end

  test "prints 'error' if communication with the application fails", _context do
    :meck.expect(Exdm.Remote, :is_running?, fn _ -> {:error, "foo"} end)

    result = capture_io(fn ->
      Mix.Tasks.Deployment.IsRunning.run([@stage])
    end)

    :meck.unload(Exdm.Remote)

    assert result == "error\n"
  end
end
