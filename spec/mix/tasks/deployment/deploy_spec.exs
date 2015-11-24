defmodule Mix.Tasks.Deployment.DeploySpec do
  use ESpec

  let :stage, do: "stage"
  let :stage_atom, do: String.to_atom(stage)
  let :remote_version, do: "0.2.3"

  before do
    :meck.expect(Exdm.Remote, :get_version, fn _ -> {:ok, remote_version} end)
    :meck.expect(Exdm, :deploy, fn _ -> {:ok} end)
  end
  finally do
    :meck.unload(Exdm.Remote)
    :meck.unload(Exdm.Local)
    :meck.unload(Exdm)
  end

  context "when the deploy upgrade is possible" do
    before do: :meck.expect(Exdm.Local, :can_transition_from, fn _ -> {:ok} end)

    it "deploys" do
      Mix.Tasks.Deployment.Deploy.run([stage])

      expect Exdm |> to accepted :deploy, [stage_atom]
    end
  end

  context "when the deploy cannot transition" do
    before do: :meck.expect(Exdm.Local, :can_transition_from, fn _ -> {:error, :nope} end)

    it "fails" do
      Mix.Tasks.Deployment.Deploy.run([stage])

      expect Exdm |> to_not accepted :deploy, [stage_atom]
    end
  end
end
