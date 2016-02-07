defmodule GameSerializer do
  use Remodel
  attributes ~w(
    id players game_state
  )a

  def players(record) do
    record.players |> Enum.map(fn(player) -> player.id end)
  end

  def game_state(record) do
    record.game_state |> GameStateSerializer.to_map
  end
end
