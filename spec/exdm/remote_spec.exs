defmodule Exdm.RemoteSpec do
  use ESpec

  let :stage, do:                 :stage
  let :config, do:                "config"
  let :application_path, do:      "/foo"
  let :user_and_host, do:         "me@example.com"
  let :remote_erlang_version, do: "9.9.9"
  let :remote_version, do:        "0.2.3"
  let :start_erl_content, do:     remote_erlang_version <> " " <> remote_version <> "\n"

  context "get_version/1" do
    let :ssh_params, do: ["cat", application_path <> "/releases/start_erl.data"]

    before do
      :meck.expect(Exdm.Config, :load!, fn _stage -> config end)
      :meck.expect(Exdm.Config, :application_path!, fn _ -> application_path end)
      :meck.expect(Exdm.Config, :user_and_host!, fn _config -> user_and_host end)
      :meck.expect(Exdm.Connection, :execute, fn _stage, _ssh_params -> {:ok, start_erl_content} end)
    end

    finally do
      :meck.unload(Exdm.Config)
      :meck.unload(Exdm.Connection)
    end

    it "returns the version running on the remote machine" do
      {:ok, version} = Exdm.Remote.get_version(stage)

      expect Exdm.Connection |> to(accepted :execute, [
        stage, ssh_params
      ])

      expect version |> to(eq remote_version)
    end
  end
end
