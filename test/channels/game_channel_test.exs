defmodule ElMascarar.GameChannelTest do
  use ElMascarar.ChannelCase

  alias ElMascarar.GameChannel

  setup do
    player = Repo.insert!(%Player{})
    {:ok, reply, socket} =
      socket("player:#{player.id}", %{player_id: player.id})
      |> subscribe_and_join(GameChannel, "games:lobby")

    {:ok, %{reply: reply}}
  end

  test "joining lobby responds with player id and game id", %{reply: reply} do
    assert %{player_id: _, game_id: _} = reply
  end
end
