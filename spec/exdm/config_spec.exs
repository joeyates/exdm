defmodule Exdm.ConfigSpec do
  use ESpec

  let :stage, do: :stage
  let :config do
    [
      application_path: application_path,
      host:             host,
      user:             user
    ]
  end
  let :application_path, do: "/foo"
  let :host, do: "example.com"
  let :user, do: "deploy"

  context "load/1" do
    context "when there is no exdm configuration" do
      before do: Application.put_env(:exdm, stage, config)
      finally do: Application.delete_env(:exdm, stage)

      it "returns exdm configuration" do
        {:ok, result} = Exdm.Config.load(stage)

        expect result |> to eq config
      end
    end

    context "when there is no exdm configuration" do
      it "fails" do
        {:error, reason} = Exdm.Config.load(stage)

        expect reason |> to eq :no_env
      end
    end
  end

  context "load!/1" do
    context "when there is no exdm configuration" do
      before do: Application.put_env(:exdm, stage, config)
      finally do: Application.delete_env(:exdm, stage)

      it "returns exdm configuration" do
        result = Exdm.Config.load!(stage)

        expect result |> to eq config
      end
    end

    context "when there is no exdm configuration" do
      it "raises" do
        expect do: fn -> Exdm.Config.load!(stage) end
        |> to raise_exception Exdm.Config.ConfigurationNotFoundError
      end
    end
  end

  context "application_path/1" do
    it "returns the application_path" do
      {:ok, result} = Exdm.Config.application_path(config)

      expect result |> to eq application_path
    end

    context "when there is no application_path" do
      it "fails" do
        config = Keyword.drop(config, [:application_path])
        {:error, reason} = Exdm.Config.application_path(config)

        expect reason |> to eq :no_application_path
      end
    end
  end

  context "application_path!/1" do
    it "returns the application_path" do
      result = Exdm.Config.application_path!(config)

      expect result |> to eq application_path
    end

    context "when there is no application_path" do
      it "raises" do
        config = Keyword.drop(config, [:application_path])

        expect do: fn -> Exdm.Config.application_path!(config) end
        |> to raise_exception Exdm.Config.ValueNotSetError
      end
    end
  end

  context "user_and_host/1" do
    it "combines user and host" do
      {:ok, result} = Exdm.Config.user_and_host(config)

      expect result |> to eq(user <> "@" <> host)
    end

    context "when there is no host" do
      it "fails" do
        config = Keyword.drop(config, [:host])
        {:error, reason} = Exdm.Config.user_and_host(config)

        expect reason |> to eq :no_host
      end
    end

    context "when there is no user" do
      it "returns the host" do
        config = Keyword.drop(config, [:user])
        {:ok, result} = Exdm.Config.user_and_host(config)

        expect result |> to eq host
      end
    end
  end
end
