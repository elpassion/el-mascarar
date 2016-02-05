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

  def join("games:" <> game_id, payload, socket) do
    send(self, {:after_join, %{game_id: game_id}})
    {:ok, socket}
  end

  def terminate(_message, socket) do

  end

  def handle_info({:after_join, %{game_id: game_id}}, socket) do
    game = Repo.get(Game, game_id) |> Repo.preload :players
    game_players = game.players |> Enum.map fn(player) ->
      player.id
    end
    serialized_game = %{ game_state: game.game_state, id: game.id, players: game_players }
    broadcast socket, "game", %{game: serialized_game}
    {:noreply, socket}
  end

  def handle_in("switch", %{"index" => index, "switch" => switch}, socket) do
    "games:" <> game_id = socket.topic
    game = Repo.get!(Game, game_id) |> Game.switch(index, switch) |> Repo.preload :players
    game_players = game.players |> Enum.map fn(player) ->
      player.id
    end
    serialized_game = %{ game_state: game.game_state, id: game.id, players: game_players }
    broadcast socket, "game", %{game: serialized_game}
    {:noreply, socket}
  end

  def handle_in("reveal", _, socket) do
    "games:" <> game_id = socket.topic
    {player_game, rest_game} = Repo.get!(Game, game_id) |> Game.reveal
    game_players = player_game.players |> Enum.map fn(player) ->
      player.id
    end

    push socket, "game", %{game: %{game_state: player_game.game_state, id: player_game.id, players: game_players}}
    broadcast_from socket, "game", %{game: %{game_state: rest_game.game_state, id: rest_game.id, players: game_players}}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
