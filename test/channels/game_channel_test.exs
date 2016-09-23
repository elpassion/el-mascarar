defmodule ElMascarar.GameChannelTest do
  use ElMascarar.ChannelCase

  alias ElMascarar.GameChannel

  setup do
    player = Repo.insert!(%Player{})
    {:ok, reply, socket} =
      socket("player:#{player.id}", %{player_id: player.id})
      |> subscribe_and_join(GameChannel, "games:lobby")

    {:ok, %{reply: reply, socket: socket}}
  end

  # test "joining lobby responds with player id and game id", %{reply: reply} do
  #   assert %{player_id: _, game_id: _} = reply
  # end

  # test "joining games: responds with game", %{socket: socket, reply: reply} do
  #   socket |>
  #     subscribe_and_join(GameChannel, "games:#{reply.game_id}")
  #   assert_broadcast "game", %{game: %{game_state: _, players: _, id: _}}
  # end
end
