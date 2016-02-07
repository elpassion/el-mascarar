defmodule GameStateSerializer do
  use Remodel
  attributes ~w(
    players free_cards round court_money active_player
  )a

  def players(record) do
    record["players"] |> Enum.map(fn(player) ->
      %{card: player["card"], money: player["money"]}
    end)
  end

  def free_cards(record) do
    record["free_cards"]
  end

  def round(record) do
    record["round"]
  end

  def court_money(record) do
    record["court_money"]
  end

  def active_player(record) do
    record["active_player"]
  end
end
