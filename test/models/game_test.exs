defmodule ElMascarar.GameTest do
  use ElMascarar.ModelCase

  alias ElMascarar.Game
  alias ElMascarar.Player
  alias ElMascarar.Card

  test "create" do
    game = Game.create |> Game.preload
    assert Enum.count(game.cards) == 6
  end

  test "serialize_to_game_state" do
    game = Game.create |> Game.preload
    player0 = Repo.insert!(%Player{money: 0, game_id: game.id})
    player1 = Repo.insert!(%Player{money: 0, game_id: game.id, card: Enum.at(game.cards, 1)})
    player2 = Repo.insert!(%Player{money: 0, game_id: game.id, card: Enum.at(game.cards, 2)})
    player3 = Repo.insert!(%Player{money: 0, game_id: game.id, card: Enum.at(game.cards, 3)})
    Repo.update!(Card.changeset(Enum.at(game.cards, 0), %{player_id: player0.id}))
    Repo.update!(Card.changeset(Enum.at(game.cards, 1), %{player_id: player1.id}))
    Repo.update!(Card.changeset(Enum.at(game.cards, 2), %{player_id: player2.id}))
    Repo.update!(Card.changeset(Enum.at(game.cards, 3), %{player_id: player3.id}))
    game = Repo.get!(Game, game.id) |> Game.preload
    assert Game.serialize_to_game_state(game) == %{
      court_money: 0,
      free_cards: [%{card: "Judge", true_card: "Judge"}, %{card: "Liar", true_card: "Liar"}],
      players: [
        %{card: "Queen", money: 0, true_card: "Queen"},
        %{card: "King", money: 0, true_card: "King"},
        %{card: "Thief", money: 0, true_card: "Thief"},
        %{card: "Bishop", money: 0, true_card: "Bishop"}
      ],
      round: 0,
      id: game.id,
    }

  end
end
