defmodule Exdm.LocalSpec do
  use ESpec

  let :app_name, do:             :foo
  let :app_name_string, do:      "foo"
  let :previous_version, do:     "0.2.2"
  let :local_version, do: "0.2.3"

  context "get_version/0" do
    before do
      :meck.expect(Mix.Project, :config, fn -> %{app: app_name()} end)
      :meck.expect(ReleaseManager.Utils, :get_last_release, fn _ -> local_version() end)
      :meck.expect(ReleaseManager.Utils, :rel_dest_path, fn _ -> relup_path() end)
    end

    finally do
      :meck.unload(Mix.Project)
      :meck.unload(ReleaseManager.Utils)
    end

    it "returns the version of the latest local release" do
      {:ok, version} = Exdm.Local.get_version

      expect version |> to(eq local_version())
    end
  end

  context "can_transition_from/1" do
    let :relup_path, do: "/baz/relup"
    let :relup do
      [{
        String.to_charlist(local_version()),
        [{String.to_charlist(previous_version()), [], [:point_of_no_return]}],
        [{String.to_charlist(previous_version()), [], [:point_of_no_return]}]
      }]
    end

    context "when the local relup transitions to the supplied version" do
      before do
        :meck.expect(ReleaseManager.Utils, :rel_dest_path, fn _ -> relup_path() end)
        :meck.new(:file, [:unstick, :passthrough])
        :meck.expect(:file, :consult, fn _ -> {:ok, relup()} end)
      end

      finally do
        :meck.unload(:file)
        :meck.unload(ReleaseManager.Utils)
      end

      it "succeeds" do
        {result} = Exdm.Local.can_transition_from(previous_version())

        expect result |> to(eq :ok)
      end
    end

    context "when the local version is already deployed" do
      before do
        :meck.expect(ReleaseManager.Utils, :rel_dest_path, fn _ -> relup_path() end)
        :meck.new(:file, [:unstick, :passthrough])
        :meck.expect(:file, :consult, fn _ -> {:ok, relup()} end)
      end

      finally do
        :meck.unload(:file)
        :meck.unload(ReleaseManager.Utils)
      end

      it "fails" do
        {:error, reason} = Exdm.Local.can_transition_from(local_version())

        expect reason |> to(eq "The currently available release (#{local_version()}) is already deployed")
      end
    end

    context "when the relup previous version does not match the remote version" do
      let :another_version, do: "9.9.9"

      before do
        :meck.expect(ReleaseManager.Utils, :rel_dest_path, fn _ -> relup_path() end)
        :meck.new(:file, [:unstick, :passthrough])
        :meck.expect(:file, :consult, fn _ -> {:ok, relup()} end)
      end

      finally do
        :meck.unload(:file)
        :meck.unload(ReleaseManager.Utils)
      end

      it "fails" do
        {:error, reason} = Exdm.Local.can_transition_from(another_version())
        expect reason |> to(eq "The currently available release updates from version #{previous_version()} to version #{local_version()}, but the deployed version is #{another_version()}")
      end
    end

    context "when the local relup is missing" do
      before do
        :meck.expect(ReleaseManager.Utils, :rel_dest_path, fn _ -> relup_path() end)
        :meck.new(:file, [:unstick, :passthrough])
        :meck.expect(:file, :consult, fn _ -> {:error, :enoent} end)
      end

      finally do
        :meck.unload(:file)
        :meck.unload(ReleaseManager.Utils)
      end

      it "fails" do
        {:error, reason} = Exdm.Local.can_transition_from(previous_version())

        expect reason |> to(eq "No relup file was found")
      end
    end
  end

  context "tarball_pathname/0" do
    let :releases_path, do: "releases_path"

    before do
      :meck.expect(ReleaseManager.Utils, :rel_dest_path, fn _ -> releases_path() end)
      :meck.expect(ReleaseManager.Utils, :get_last_release, fn _ -> local_version() end)
    end

    finally do
      :meck.unload(ReleaseManager.Utils)
    end

    it "builds a path using the version" do
      {:ok, path} = Exdm.Local.tarball_pathname

      expect path |> to(eq Path.join([releases_path(), local_version(), "exdm.tar.gz"]))
    end
  end
end
