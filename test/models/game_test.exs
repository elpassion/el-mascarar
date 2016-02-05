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

  test "switch" do
    game = Game.create |> Game.ready |> Game.switch(1, true)
    assert game.game_state == %{active_player: 1, court_money: 0, free_cards: [%{card: "Unknown", true_card: "Thief"}, %{card: "Unknown", true_card: "Liar"}],
                                          players: [%{card: "SwitchedOrNot", money: 6, true_card: "King"}, %{card: "SwitchedOrNot", money: 6, true_card: "Queen"}, %{card: "Unknown", money: 6, true_card: "Judge"}, %{card: "Unknown", money: 6, true_card: "Bishop"}], round: 1}
  end

  test "reveal" do
    {player_game, rest_game} = Game.create |> Game.ready |> Game.switch(1, false) |> Game.switch(0, false) |> Game.switch(0, false) |> Game.switch(0, false) |> Game.reveal
    assert rest_game.game_state == %{active_player: 1, court_money: 0, free_cards: [%{card: "Unknown", true_card: "Thief"}, %{card: "Unknown", true_card: "Liar"}],
                                                players: [%{card: "Revealed", money: 6, true_card: "Queen"}, %{card: "Unknown", money: 6, true_card: "King"}, %{card: "Unknown", money: 6, true_card: "Judge"}, %{card: "Unknown", money: 6, true_card: "Bishop"}], round: 5}


  end
end