defmodule NischeebLazertag.GenServers.TCPServer do
  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, socket} = :gen_tcp.listen(2052, [:binary, packet: :line, nodelay: true, active: true, reuseaddr: true])
    Logger.info("Accepting connections")
    send(__MODULE__, :loop)
    {:ok, %{socket: socket}}
  end

  def handle_info(:loop, state) do
    loop_acceptor(state.socket)

    {:noreply, state}
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, {ip, _client_port}} = :inet.peername(client)

    case NischeebLazertag.GenServers.TCPPlayer.start_link(client, ip) do
      {:ok, pid} -> :ok = :gen_tcp.controlling_process(client, pid)
      _ -> 42
    end

    loop_acceptor(socket)
  end
end
