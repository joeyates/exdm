defmodule Mix.Tasks.Deployment.IsRunning do
  use Mix.Task

  @shortdoc "Indicates wheteher the application is running on the host"
  def run([stage]) do
    handle_is_running(Exdm.Remote.is_running?(String.to_atom(stage)))
  end

  defp handle_is_running({:ok, :yes}) do
    IO.puts "yes"
  end
  defp handle_is_running({:ok, :no}) do
    IO.puts "no"
  end
  defp handle_is_running({:error, _reason}) do
    IO.puts "error"
  end
end
