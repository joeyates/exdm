defmodule Mix.Tasks.Deployment.LocalSpec do
  use ESpec
  import ExUnit.CaptureIO

  let :local_version, do: "0.2.3"

  before do: :meck.expect(Exdm.Local, :get_version, fn -> {:ok, local_version} end)
  finally do: :meck.unload(Exdm.Local)

  it "prints the version running on the local machine" do
    result = capture_io(fn ->
      Mix.Tasks.Deployment.Local.run([])
    end)

    expect result |> to eq local_version <> "\n"
  end
end
