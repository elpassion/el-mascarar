defmodule ElMascarar.GameChannelTest do
  use ElMascarar.ChannelCase

  alias ElMascarar.GameChannel

  setup do
    player = Repo.insert!(%Player{})
    {:ok, reply, socket} =
      socket("player:#{player.id}", %{player_id: player.id})
      |> subscribe_and_join(GameChannel, "games:lobby")

    {:ok, %{socket: socket, player: player, reply: reply}}
  end

  test "joining lobby responds with player id", %{player: player, reply: reply} do
    assert reply == %{player_id: player.id}
  end

  test "join:game when there are no games", %{socket: socket} do
    ref = push socket, "join:game"
    assert_reply ref, :ok, %{game: _}
  end

  test "join:game when there is a non empty game", %{socket: socket} do
    game = Repo.insert!(%Game{})
    player = Repo.insert!(%Player{game_id: game.id})
    ref = push socket, "join:game"
    game_id = game.id
    assert_reply ref, :ok, %{game: %{id: ^game_id}}
  end
end
