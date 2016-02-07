defmodule GameSerializer do
  alias ElMascarar.Game

  use Remodel
  attributes ~w(
    id players game_state status
  )a

  def players(game) do
    game.players |> Enum.map(fn(player) -> player.id end)
  end

  def game_state(game) do
    game.game_state |> GameStateSerializer.to_map
  end

  def status(game) do
    game |> Game.status
  end
end
