defmodule Exdm.Connection do
  def execute(stage, args) do
    config = Exdm.Config.load!(stage)
    {:ok, user_and_host} = Exdm.Config.user_and_host(config)
    command = Enum.join(args, " ")
    handle_execute(System.cmd("ssh", [user_and_host, "bash -lc \"" <> command <> "\""]))
  end

  defp handle_execute({content, 0}) do
    {:ok, content}
  end
  defp handle_execute({content, exit_code}) do
    {:error, content, exit_code}
  end

  def upload(stage, local_file, remote_path) do
    config = Exdm.Config.load!(stage)
    {:ok, user_and_host} = Exdm.Config.user_and_host(config)
    {_content, 0} = System.cmd("ssh", [user_and_host, "mkdir", "-p", remote_path])
    {_content, 0} = System.cmd("scp", [local_file, user_and_host <> ":" <> remote_path])
    {:ok}
  end

  """
  With Erlang 7.x, this doesn't work without a specially configured
  ssh server on the remote host, as Erlang's SSH key exchange system
  only accepts the 'diffie-hellman-group1-sha1' algorithm, which openssh
  has (rightly) deprecated.

    * http://erlang.org/pipermail/erlang-bugs/2015-August/005043.html

  defp do_execute(args)  do
    :ssh.start
    options = [{:user, 'deploy'}]
    {:ok, connection} = :ssh.connect(
      'example.com', 22, options
    )
    {:ok, channel_pid} = :ssh_sftp.start_channel(connection)
    {:ok, content} = :ssh_sftp.read_file(channel_pid, start_erl_path)
  end
  """
end
