defmodule Mix.Tasks.Deployment.DeployTest do
  use Exdm.TestCase

  @stage                "stage"
  @remote_version       "0.2.3"

  test "when the deploy upgrade is possible, it deploys", _context do
    :meck.expect(Exdm.Remote, :get_version, fn _ -> {:ok, @remote_version} end)
    :meck.expect(Exdm.Local, :can_transition_from, fn _ -> {:ok} end)
    :meck.expect(Exdm, :deploy, fn _ -> {:ok} end)

    Mix.Tasks.Deployment.Deploy.run([@stage])

    :meck.unload(Exdm.Remote)
    :meck.unload(Exdm.Local)

    :meck.validate(Exdm)
    :meck.unload(Exdm)
  end

  test "when the deploy cannot transition, it fails", _context do
    :meck.expect(Exdm.Remote, :get_version, fn _ -> {:ok, @remote_version} end)
    :meck.expect(Exdm.Local, :can_transition_from, fn _ -> {:error, :nope} end)
    :meck.expect(Exdm, :deploy, fn _ -> {:ok} end)

    Mix.Tasks.Deployment.Deploy.run([@stage])

    :meck.unload(Exdm.Remote)
    :meck.unload(Exdm.Local)

    assert :meck.num_calls(Exdm, :deploy, 0) == 0

    :meck.unload(Exdm)
  end
end
