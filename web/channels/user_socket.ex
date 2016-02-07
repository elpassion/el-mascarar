defmodule ElMascarar.UserSocket do
  use Phoenix.Socket
  alias ElMascarar.Player
  alias ElMascarar.Repo

  ## Channels
  channel "games:*", ElMascarar.GameChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(_params, socket) do
    player_id = Repo.insert!(%Player{}).id
    {:ok, assign(socket, :player_id, player_id)}
  end

  def id(socket), do: "player:#{socket.assigns.player_id}"
end
