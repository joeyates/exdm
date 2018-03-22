# Adapted from exrm,
# Copyright (c) 2014 Paul Schoenfelder

defmodule ReleaseManager.Utils do
  @doc """
  Get a list of tuples representing the previous releases:

  ## Examples

      get_releases #=> [{"test", "0.0.1"}, {"test", "0.0.2"}]

  """
  def get_releases(project) do
    release_path = Path.join([File.cwd!, "rel", project, "releases"])
    case release_path |> File.exists? do
      false -> []
      true  ->
        release_path
        |> File.ls!
        |> Enum.reject(fn entry -> entry in ["RELEASES", "start_erl.data"] end)
        |> Enum.map(fn version -> {project, version} end)
    end
  end

  @doc """
  Get the most recent release prior to the current one
  """
  def get_last_release(project) do
    hd(project |> get_releases |> Enum.map(fn {_, v} -> v end) |> sort_versions)
  end

  @doc """
  Sort a list of versions, latest one first. Tries to use semver version
  compare, but can fall back to regular string compare.
  """
  def sort_versions(versions) do
    versions
    |> Enum.map(fn ver ->
        # Special handling for git-describe versions
        compared = case Regex.named_captures(~r/(?<ver>\d+\.\d+\.\d+)-(?<commits>\d+)-(?<sha>[A-Ga-g0-9]+)/, ver) do
          nil ->
            {:standard, ver, nil}
          %{"ver" => version, "commits" => n, "sha" => sha} ->
            {:describe, <<version::binary, ?+, n::binary, ?-, sha::binary>>, String.to_integer(n)}
        end
        {ver, compared}
      end)
    |> Enum.sort(
      fn {_, {v1type, v1str, v1_commits_since}}, {_, {v2type, v2str, v2_commits_since}} ->
        case { parse_version(v1str), parse_version(v2str) } do
          {{:semantic, v1}, {:semantic, v2}} ->
            case Version.compare(v1, v2) do
              :gt -> true
              :eq ->
                case {v1type, v2type} do
                  {:standard, :standard} -> v1 > v2 # probably always false
                  {:standard, :describe} -> false   # v2 is an incremental version over v1
                  {:describe, :standard} -> true    # v1 is an incremental version over v2
                  {:describe, :describe} ->         # need to parse out the bits
                    v1_commits_since > v2_commits_since
                end
              :lt -> false
            end;
          {{_, v1}, {_, v2}} ->
            v1 >  v2
        end
      end)
    |> Enum.map(fn {v, _} -> v end)
  end

  defp parse_version(ver) do
    case Version.parse(ver) do
      {:ok, semver} -> {:semantic, semver}
      :error        -> {:nonsemantic, ver}
    end
  end

  @doc """
  Get the path to a file located in the rel directory of the current project.
  You can pass either a file name, or a list of directories to a file, like:

      iex> ReleaseManager.Utils.rel_dest_path "relx.config"
      "path/to/project/rel/relx.config"

      iex> ReleaseManager.Utils.rel_dest_path ["<project>", "lib", "<project>.appup"]
      "path/to/project/rel/<project>/lib/<project>.appup"

  """
  def rel_dest_path(files) when is_list(files), do: Path.join([rel_dest_path()] ++ files)
  def rel_dest_path(file),                      do: Path.join(rel_dest_path(), file)
  @doc "Get the rel path of the current project."
  def rel_dest_path,                            do: Path.join(File.cwd!, "rel")
end
