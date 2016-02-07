defmodule ElMascarar.GameTest do
  use ElMascarar.ModelCase

  alias ElMascarar.Game

  test "create" do
    game = Game.create
    assert game.game_state == %{active_player: 0, court_money: 0, free_cards: [%{card: "Thief", true_card: "Thief"}, %{card: "Liar", true_card: "Liar"}],
                                            players: [%{card: "Queen", money: 6, true_card: "Queen"}, %{card: "King", money: 6, true_card: "King"}, %{card: "Judge", money: 6, true_card: "Judge"}, %{card: "Bishop", money: 6, true_card: "Bishop"}], round: 0}
  end

  test "ready" do
    game = Game.create |> Game.ready
    assert game.game_state == %{active_player: 0, court_money: 0, free_cards: [%{card: "Unknown", true_card: "Thief"}, %{card: "Unknown", true_card: "Liar"}],
                                           players: [%{card: "Unknown", money: 6, true_card: "Queen"}, %{card: "Unknown", money: 6, true_card: "King"}, %{card: "Unknown", money: 6, true_card: "Judge"}, %{card: "Unknown", money: 6, true_card: "Bishop"}], round: 0}
  end
end
