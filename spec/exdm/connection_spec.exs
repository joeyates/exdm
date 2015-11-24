defmodule Exdm.ConnectionSpec do
  use ESpec

  let :stage, do: :stage
  let :config, do: "config"
  let :params, do: ["foo"]
  let :user_and_host, do: "user@example.com"
  let :output, do: "output"
  let :local_pathname, do: "/local/path/file.tgz"
  let :remote_path, do: "/remote/path"

  context "execute/2" do
    before do
      :meck.expect(Exdm.Config, :load!, fn _ -> config end)
      :meck.expect(Exdm.Config, :user_and_host, fn _ -> {:ok, user_and_host} end)
      :meck.expect(System, :cmd, fn _, _ -> {output, 0} end)
    end

    finally do
      :meck.unload(Exdm.Config)
      :meck.unload(System)
    end

    it "runs a command via SSH" do
      {:ok, result} = Exdm.Connection.execute(stage, params)

      expect System |> to accepted :cmd, [
        "ssh", [user_and_host, "bash -lc \"foo\""]
      ]
      expect result |> to eq output
    end
  end

  context "upload/3" do
    before do
      :meck.expect(Exdm.Config, :load!, fn _ -> config end)
      :meck.expect(Exdm.Config, :user_and_host, fn _ -> {:ok, user_and_host} end)
      :meck.expect(System, :cmd, fn _, _ -> {output, 0} end)
    end

    finally do
      :meck.unload(Exdm.Config)
      :meck.unload(System)
    end

    it "uploads a file" do
      {:ok} = Exdm.Connection.upload(stage, local_pathname, remote_path)

      expect System |> to accepted :cmd, [
        "ssh", [user_and_host, "mkdir", "-p", remote_path]
      ]
      expect System |> to accepted :cmd, [
        "scp", [local_pathname, user_and_host <> ":" <> remote_path]
      ]
    end
  end
end
