defmodule Mix.Tasks.Deployment.IsRunningSpec do
  use ESpec
  import ExUnit.CaptureIO

  let :stage, do: "stage"

  finally do: :meck.unload(Exdm.Remote)

  context "when the application is running" do
    before do: :meck.expect(Exdm.Remote, :is_running?, fn _ -> {:ok, :yes} end)

    it "prints 'yes'" do
      result = capture_io(fn ->
        Mix.Tasks.Deployment.IsRunning.run([stage()])
      end)

      expect result |> to(eq "yes\n")
    end
  end

  context "when the application is not running" do
    before do: :meck.expect(Exdm.Remote, :is_running?, fn _ -> {:ok, :no} end)

    it "prints 'no'" do
      result = capture_io(fn ->
        Mix.Tasks.Deployment.IsRunning.run([stage()])
      end)

      expect result |> to(eq "no\n")
    end
  end

  context "if communication with the application fails" do
    before do: :meck.expect(Exdm.Remote, :is_running?, fn _ -> {:error, "foo"} end)

    it "prints 'error'" do
      result = capture_io(fn ->
        Mix.Tasks.Deployment.IsRunning.run([stage()])
      end)

      expect result |> to(eq "error\n")
    end
  end
end
