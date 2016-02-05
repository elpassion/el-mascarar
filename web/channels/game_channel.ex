defmodule ElMascarar.GameChannel do
  use ElMascarar.Web, :channel

  def join("games:lobby", _, socket) do
    game = Game.find_or_create()
    player =
      Repo.get!(Player, socket.assigns.player_id)
      |> Player.changeset(%{game_id: game.id})
      |> Repo.update!

    response = %{player_id: player.id, game_id: game.id}
    {:ok, response, socket}
  end

  def join("games:" <> game_id, _, socket) do
    broadcast socket, "game", %{game: Repo.get(Game, game_id)}
    {:ok, socket}
  end

  def handle_in("switch", %{index: index, switch: switch}, socket) do
    "games:" <> game_id = socket.topic
    game = Repo.get!(Game, game_id) |> Game.switch(index, switch)
    broadcast socket, "game", %{game: game}
    {:ok, socket}
  end

  def handle_in("reveal", _, socket) do
    "games:" <> game_id = socket.topic
    {player_game, rest_game} = Repo.get!(Game, game_id) |> Game.reveal
    push socket, "game", %{game: player_game}
    broadcast_from socket, "game", %{game: rest_game}
    {:ok, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
