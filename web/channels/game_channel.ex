defmodule ElMascarar.GameChannel do
  use ElMascarar.Web, :channel

  def join("games:lobby", _, socket) do
    player = Repo.get!(Player, socket.assigns.player_id)
    response = %{"player_id": player.id}
    {:ok, response, socket}
  end

  def join("games:" <> game_id, _, socket) do
    response = %{"wawa": "wiwa"}
    {:ok, response, socket}
  end

  def handle_in("join:game", payload, socket) do
    game = Game.find_or_create()
    player = Repo.get!(Player, socket.assigns.player_id)
    changeset = Player.changeset(player, %{game_id: game.id})
    Repo.update!(changeset)

    {:reply, {:ok, %{game: game}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
