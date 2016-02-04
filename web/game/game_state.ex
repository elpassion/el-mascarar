defmodule ElMascarar.GameState do

  def create_game(card_names) do
    %{
      players: Enum.take(card_names, 4) |> create_players_list,
      free_cards: Enum.drop(card_names, 4) |> create_free_cards_list,
      court_money: 0,
      round: 0,
    }
  end

  def ready(game) do
    %{
      players: game.players |> hide_cards,
      free_cards: game.free_cards |> hide_cards,
      court_money: game.court_money,
      round: game.round,
    }
  end

  def switch(game, card_number, switch) do
    active_player_card_number = rem(game.round, 4)
    if card_number == active_player_card_number do
      raise "CannotSwitchOwnCard"
    else
      game = ready(game)
      allPreviousCards = game.players ++ game.free_cards
      myPreviousCard = Enum.at(game.players, active_player_card_number)
      theirPreviousCard = Enum.at(allPreviousCards, card_number)
      myCard = myPreviousCard |> Map.put(:true_card, theirPreviousCard.true_card) |> Map.put(:card, "SwitchedOrNot")
      theirCard = theirPreviousCard |> Map.put(:true_card, myPreviousCard.true_card) |> Map.put(:card, "SwitchedOrNot")
      allCards = allPreviousCards |> List.replace_at(active_player_card_number, myCard) |> List.replace_at(card_number, theirCard)
      %{
        players: Enum.take(allCards, 4),
        free_cards: Enum.drop(allCards, 4),
        court_money: game.court_money,
        round: game.round + 1,
      }
    end
  end

  def reveal(game) do
    if game.round < 4 do
      raise "NotSupported"
    else
      game = ready(game)
      active_player_card_number = rem(game.round, 4)
      myPreviousCard = Enum.at(game.players, active_player_card_number)
      myCard = myPreviousCard |> Map.put(:card, "Revealed")
      %{
        players: game.players |> List.replace_at(active_player_card_number, myCard),
        free_cards: game.free_cards,
        court_money: game.court_money,
        round: game.round + 1,
      }
    end
  end

  def hide_cards(cards) do
    Enum.map(cards, fn(card) -> Map.put(card, :card, "Unknown") end)
  end

  defp create_players_list(card_names) do
    Enum.map(card_names, fn(card_name) -> %{ card: card_name, true_card: card_name, money: 6 } end)
  end

  defp create_free_cards_list(card_names) do
    Enum.map(card_names, fn(card_name) -> %{ card: card_name, true_card: card_name } end)
  end
end
