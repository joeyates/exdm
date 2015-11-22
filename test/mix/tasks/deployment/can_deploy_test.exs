defmodule Mix.Tasks.Deployment.CanDeployTest do
  use Exdm.TestCase
  import ExUnit.CaptureIO

  @stage                "stage"
  @remote_version       "0.2.3"

  test "when the relup file transitions from the remote version to the local version, prints yes", _context do
    :meck.expect(Exdm.Remote, :get_version, fn _ -> {:ok, @remote_version} end)
    :meck.expect(Exdm.Local, :can_transition_from, fn @remote_version -> {:ok} end)

    result = capture_io(fn ->
      Mix.Tasks.Deployment.CanDeploy.run([@stage])
    end)

    assert result == "yes\n"

    :meck.unload(Exdm.Remote)
    :meck.unload(Exdm.Local)
  end

  test "when the current release cannot transition from the deployed version, prints 'no'", _context do
    some_reason = "some_reason"
    :meck.expect(Exdm.Remote, :get_version, fn _ -> {:ok, @remote_version} end)
    :meck.expect(Exdm.Local, :can_transition_from, fn @remote_version -> {:error, some_reason} end)

    result = capture_io(fn ->
      error = catch_error(Mix.Tasks.Deployment.CanDeploy.run([@stage]))
      assert error.message == some_reason
    end)

    assert result == "no\n"

    :meck.unload(Exdm.Local)
    :meck.unload(Exdm.Remote)
  end
end
