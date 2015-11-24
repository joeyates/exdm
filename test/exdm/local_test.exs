defmodule Exdm.LocalTest do
  use Exdm.TestCase

  @app_name             :foo
  @app_name_string      "foo"
  @previous_version     "0.2.2"
  @local_version        "0.2.3"
  @relup_path           "/baz/relup"
  @relup                [{
    String.to_char_list(@local_version),
    [{String.to_char_list(@previous_version), [], [:point_of_no_return]}],
    [{String.to_char_list(@previous_version), [], [:point_of_no_return]}]
  }]

  test "get_version/0 returns the version of the latest local release", _context do
    :meck.expect(Mix.Project, :config, fn -> %{app: @app_name} end)
    :meck.expect(ReleaseManager.Utils, :get_last_release, fn _ -> @local_version end)
    :meck.expect(ReleaseManager.Utils, :rel_dest_path, fn _ -> @relup_path end)

    {:ok, version} = Exdm.Local.get_version

    :meck.unload(Mix.Project)
    :meck.unload(ReleaseManager.Utils)

    assert version == @local_version
  end

  test "can_transition_from/1 succeeds if the local relup transitions to the supplied version" do
    :meck.expect(ReleaseManager.Utils, :rel_dest_path, fn _ -> @relup_path end)
    :meck.new(:file, [:unstick, :passthrough])
    :meck.expect(:file, :consult, fn @relup_path -> {:ok, @relup} end)

    {result} = Exdm.Local.can_transition_from(@previous_version)

    :meck.unload(:file)
    :meck.unload(ReleaseManager.Utils)

    assert result == :ok
  end

  test "can_transition_from/1 fails if the local version is already deployed" do
    :meck.expect(ReleaseManager.Utils, :rel_dest_path, fn _ -> @relup_path end)
    :meck.new(:file, [:unstick, :passthrough])
    :meck.expect(:file, :consult, fn @relup_path -> {:ok, @relup} end)

    {:error, reason} = Exdm.Local.can_transition_from(@local_version)

    :meck.unload(:file)
    :meck.unload(ReleaseManager.Utils)

    assert reason == "The currently available release (#{@local_version}) is already deployed"
  end

  test "can_transition_from/1 fails if the relup previous version does not match the remote version" do
    :meck.expect(ReleaseManager.Utils, :rel_dest_path, fn _ -> @relup_path end)
    :meck.new(:file, [:unstick, :passthrough])
    :meck.expect(:file, :consult, fn @relup_path -> {:ok, @relup} end)

    another_version = "9.9.9"
    {:error, reason} = Exdm.Local.can_transition_from(another_version)

    :meck.unload(:file)
    :meck.unload(ReleaseManager.Utils)

    assert reason == "The currently available release updates from version #{@previous_version} to version #{@local_version}, but the deployed version is #{another_version}"
  end

  test "can_transition_from/1 fails if the local relup is missing" do
    :meck.expect(ReleaseManager.Utils, :rel_dest_path, fn _ -> @relup_path end)
    :meck.new(:file, [:unstick, :passthrough])
    :meck.expect(:file, :consult, fn @relup_path -> {:error, :enoent} end)

    {:error, reason} = Exdm.Local.can_transition_from(@previous_version)

    :meck.unload(:file)
    :meck.unload(ReleaseManager.Utils)

    assert reason == "No relup file was found"
  end

  test "tarball_pathname/0 builds a path using the version" do
    releases_path = "releases_path"
    :meck.expect(ReleaseManager.Utils, :rel_dest_path, fn _ -> releases_path end)
    :meck.expect(ReleaseManager.Utils, :get_last_release, fn _ -> @local_version end)

    {:ok, path} = Exdm.Local.tarball_pathname

    assert path == Path.join([releases_path, @local_version, "exdm.tar.gz"])
  end
end
