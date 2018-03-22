defmodule Mix.Tasks.Deployment.CanDeploySpec do
  use ESpec
  import ExUnit.CaptureIO

  let :stage, do:                "stage"
  let :remote_version, do:       "0.2.3"

  context "when the relup file transitions from the remote version to the local version" do
    before do
      :meck.expect(Exdm.Remote, :get_version, fn _ -> {:ok, remote_version()} end)
      :meck.expect(Exdm.Local, :can_transition_from, fn _ -> {:ok} end)
    end

    finally do
      :meck.unload(Exdm.Remote)
      :meck.unload(Exdm.Local)
    end

    it "prints yes" do
      result = capture_io(fn ->
        Mix.Tasks.Deployment.CanDeploy.run([stage()])
      end)

      expect result |> to(eq "yes\n")
    end
  end

  context "when the current release cannot transition from the deployed version" do
    let :some_reason, do: "some_reason"

    before do
      :meck.expect(Exdm.Remote, :get_version, fn _ -> {:ok, remote_version()} end)
      :meck.expect(Exdm.Local, :can_transition_from, fn _ -> {:error, some_reason()} end)
    end

    finally do
      :meck.unload(Exdm.Local)
      :meck.unload(Exdm.Remote)
    end

    it "prints 'no'" do
      result = capture_io(fn ->
        expect do: fn -> Mix.Tasks.Deployment.CanDeploy.run([stage()]) end
        |> to(raise_exception())
      end)

      expect result |> to(eq "no\n")
    end
  end
end
