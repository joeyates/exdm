defmodule Mix.Tasks.Deployment.RemoteSpec do
  use ESpec
  import ExUnit.CaptureIO

  let :remote_version, do: "0.2.3"

  before do
    :meck.expect(Exdm.Remote, :get_version, fn _ -> {:ok, remote_version()} end)
  end

  finally do: :meck.unload(Exdm.Remote)

  it "prints the version running on the remote machine" do
    result = capture_io(fn ->
      Mix.Tasks.Deployment.Remote.run(["stage"])
    end)

    expect result |> to(eq remote_version() <> "\n")
  end
end
