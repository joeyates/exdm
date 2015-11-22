defmodule Exdm.ConfigTest do
  use Exdm.TestCase

  @stage                 :stage
  @application_path      "/foo"
  @host                  "example.com"
  @user                  "deploy"
  @config                [
    application_path: @application_path,
    host:             @host,
    user:             @user
  ]

  test "load/1 returns exdm configuration" do
    Application.put_env(:exdm, @stage, @config)

    {:ok, result} = Exdm.Config.load(@stage)

    Application.delete_env(:exdm, @stage)

    assert result == @config
  end

  test "if there is no exdm configuration, load/1 fails" do
    {:error, reason} = Exdm.Config.load(@stage)

    assert reason == :no_env
  end

  test "load!/1 returns exdm configuration" do
    Application.put_env(:exdm, @stage, @config)

    result = Exdm.Config.load!(@stage)

    Application.delete_env(:exdm, @stage)

    assert result == @config
  end

  test "if there is no exdm configuration, load!/1 raises" do
    assert_raise Exdm.Config.ConfigurationNotFoundError, fn ->
      Exdm.Config.load!(@stage)
    end
  end

  test "application_path/1 returns the application_path" do
    {:ok, result} = Exdm.Config.application_path(@config)

    assert result == @application_path
  end

  test "when there is no application_path, application_path/1 fails" do
    config = Keyword.drop(@config, [:application_path])
    {:error, reason} = Exdm.Config.application_path(config)

    assert reason == :no_application_path
  end

  test "application_path!/1 returns the application_path" do
    result = Exdm.Config.application_path!(@config)

    assert result == @application_path
  end

  test "when there is no application_path, application_path!/1 raises" do
    config = Keyword.drop(@config, [:application_path])

    assert_raise Exdm.Config.ValueNotSetError, fn ->
      Exdm.Config.application_path!(config)
    end
  end

  test "user_and_host/1 combines user and host" do
    {:ok, result} = Exdm.Config.user_and_host(@config)

    assert result == @user <> "@" <> @host
  end

  test "when there is no host, user_and_host/1 fails" do
    config = Keyword.drop(@config, [:host])
    {:error, reason} = Exdm.Config.user_and_host(config)

    assert reason == :no_host
  end

  test "when there is no user, user_and_host/1 returns the host" do
    config = Keyword.drop(@config, [:user])
    {:ok, result} = Exdm.Config.user_and_host(config)

    assert result == @host
  end
end
