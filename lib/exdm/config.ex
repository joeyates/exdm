defmodule Exdm.Config.ConfigurationNotFoundError do
  defexception message: "exdm configuration not found"

  @spec exception(String.t) :: Exception.t
  def exception(msg) when is_binary(msg) do
    %Exdm.Config.ConfigurationNotFoundError{message: msg}
  end
end

defmodule Exdm.Config.ValueNotSetError do
  defexception message: "the requested value is not set"

  @spec exception(String.t) :: Exception.t
  def exception(msg) when is_binary(msg) do
    %Exdm.Config.ValueNotSetError{message: msg}
  end
end

defmodule Exdm.Config do
  def load(stage) do
    handle_get_env(do_get_env(stage))
  end

  defp do_get_env(stage) when is_binary(stage) do
    Application.get_env(:exdm, String.to_atom(stage))
  end
  defp do_get_env(stage) do
    Application.get_env(:exdm, stage)
  end

  defp handle_get_env(nil) do
    {:error, :no_env}
  end
  defp handle_get_env(data) do
    {:ok, data}
  end

  def load!(stage) do
    data = Application.get_env(:exdm, stage)

    if data == nil do
      raise Exdm.Config.ConfigurationNotFoundError,
        "No exdm configuration found for the '#{stage}' stage"
    else
      data
    end
  end

  def application_path(config) do
    handle_application_path(Keyword.get(config, :application_path))
  end

  defp handle_application_path(nil), do: {:error, :no_application_path}
  defp handle_application_path(path), do: {:ok, path}

  def application_path!(config) do
    get_key!(config, :application_path)
  end

  def user_and_host(config) do
    handle_user_and_host(Keyword.get(config, :user), Keyword.get(config, :host))
  end
  def user_and_host!(config) do
    handle_user_and_host!(Keyword.get(config, :user), Keyword.get(config, :host))
  end

  defp handle_user_and_host(_user, nil), do: {:error, :no_host}
  defp handle_user_and_host(nil, host), do: {:ok, host}
  defp handle_user_and_host(user, host), do: {:ok, user <> "@" <> host}

  defp handle_user_and_host!(_user, nil) do
    raise Exdm.Config.ValueNotSetError,
      "you must define a value for 'host' in exdm configuration"
  end
  defp handle_user_and_host!(user, host) do
    {:ok, result} = handle_user_and_host(user, host)
    result
  end

  defp get_key!(config, key) do
    value = Keyword.get(config, key)

    if value == nil do
      raise Exdm.Config.ValueNotSetError,
        "no value is set for the key '#{key}'"
    else
      value
    end
  end
end
