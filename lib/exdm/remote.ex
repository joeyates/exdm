defmodule Exdm.Remote do
  def get_version(stage) do
    {:ok, _erlang_version, app_version} = read_start_erl(stage)
    {:ok, app_version}
  end

  def is_running?(stage) do
    handle_ping(execute_boot_script_command(stage, ["ping"]))
  end

  def stop(stage) do
    # TODO: on success, response includes "\nok\n"
    execute_boot_script_command(stage, ["stop"])
  end

  def start(stage) do
    execute_boot_script_command(stage, ["start"])
  end

  defp handle_ping({:ok, response}) do
    if String.contains?(response, "\npong\n") do
      {:ok, :yes}
    else
      {:ok, :no}
    end
  end
  defp handle_ping({:error, response, exit_code}) do
    {:error, "got error response, exit code: #{exit_code}, message: #{response}"}
  end

  defp execute_boot_script_command(stage, args) do
    config = Exdm.Config.load!(stage)
    boot_script_path = boot_script_path!(config)
    params = [boot_script_path|args]
    Exdm.Connection.execute(stage, params)
  end

  def boot_script_path!(config) do
    application_path = Exdm.Config.application_path!(config)
    Path.join([application_path, "bin", Exdm.application_name])
  end

  def releases_path!(config) do
    application_path = Exdm.Config.application_path!(config)
    Path.join([application_path, "releases"])
  end

  defp read_start_erl(stage) do
    config = Exdm.Config.load!(stage)
    start_erl_path = Path.join([releases_path!(config), "start_erl.data"])
    params = ["cat", start_erl_path]
    handle_read_start_erl(Exdm.Connection.execute(stage, params))
  end

  defp handle_read_start_erl({:ok, content}) do
    parse_start_erl(content)
  end
  defp handle_read_start_erl({:error, reason}) do
    {:error, reason}
  end

  defp parse_start_erl(content) do
    clean = chomp(content)
    [erlang_version, app_version] = String.split(clean, " ")
    {:ok, erlang_version, app_version}
  end

  defp chomp(text) do
    String.trim_trailing(text)
  end
end
