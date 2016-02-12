defmodule ElMascarar.GameState do
  def create_game(card_names) do
    %{
      cards: card_names |> create_cards_list,
      players_money: [6, 6, 6, 6],
      court_money: 0,
      round: 0,
    }
  end

  defp create_cards_list(card_names) do
    Enum.map(card_names, fn(card_name) ->
      %{card: card_name, true_card: card_name}
    end)
  end

  defp hide_cards(cards) do
    Enum.map(cards, fn(card) -> %{card | card: "Unknown"} end)
  end

  def ready(game) do
    %{game | cards: game.cards |> hide_cards}
  end

  defp switch_cards(game, first_card_index, second_card_index) do
    first_card = Enum.at(game.cards, first_card_index)
    second_card = Enum.at(game.cards, second_card_index)
    cards =
      game.cards |>
      List.replace_at(first_card_index, second_card) |>
      List.replace_at(second_card_index, first_card)

    %{game | cards: cards}
  end

  defp mark_switched(game, first_card_index, second_card_index) do
    first_card = Enum.at(game.cards, first_card_index) |> mark_switched
    second_card = Enum.at(game.cards, second_card_index) |> mark_switched
    cards =
      game.cards |>
      List.replace_at(first_card_index, first_card) |>
      List.replace_at(second_card_index, second_card)

    %{game | cards: cards}
  end

  defp mark_switched(card) do
    %{card | card: "SwitchedOrNot"}
  end

  defp mark_revealed(game, index) do
    card = Enum.at(game.cards, index)
    card = %{card | card: "Revealed"}
    cards = List.replace_at(game.cards, index, card)
    %{game | cards: cards}
  end

  defp reveal_card(game, index) do
    card = Enum.at(game.cards, index)
    card = %{card | card: card.true_card}
    cards = List.replace_at(game.cards, index, card)
    %{game | cards: cards}
  end

  defp active_player_index(game) do
    rem(game.round, 4)
  end

  def switch(game, switched_card_index, switch?) do
    if switched_card_index == active_player_index(game) do
      raise "Cannot switch own card"
    end

    game = game |>
      ready |>
      mark_switched(active_player_index(game), switched_card_index)
    if switch? do
      game = game |> switch_cards(active_player_index(game), switched_card_index)
    end

    %{game | round: game.round + 1}
  end

  def reveal(game, owner?) do
    if game.round < 4 do
      raise "NotSupported"
    else
      game = game |> ready |> mark_revealed(active_player_index(game))
      if owner? do game = game |> reveal_card(active_player_index(game)) end
    end
    %{game | round: game.round + 1}
  end

  # def activate(game, card_name) do
  #   if game.round < 4 do
  #     raise "NotSupported"
  #   else
  #     round_player = rem(game.round, 4)
  #     if game.active_player == round_player do
  #       game = ready(game)
  #     else
  #       if Enum.at(game.players, round_player).card != "Claim:#{card_name}" do
  #         raise "NotSupported"
  #       end
  #     end
  #     my_previous_card = Enum.at(game.players, game.active_player)
  #     my_card = my_previous_card |> Map.put(:card, "Claim:#{card_name}")
  #     %{
  #       players: game.players |> List.replace_at(game.active_player, my_card),
  #       free_cards: game.free_cards,
  #       court_money: game.court_money,
  #       round: game.round,
  #       active_player: rem(game.active_player + 1, 4),
  #     }
  #   end
  # end

  # def pass(game) do
  #   new_active_player = rem(game.active_player + 1, 4)
  #   active_player_card_number = rem(game.round, 4)
  #   if new_active_player == active_player_card_number do
  #     my_previous_card = Enum.at(game.players, active_player_card_number)
  #     my_card = %{
  #       card: "Unknown",
  #       true_card: my_previous_card.true_card,
  #       money: my_previous_card.money + if my_previous_card.card == "Claim:King" do 3 else 2 end,
  #     }
  #     new_players = game.players |> List.replace_at(active_player_card_number, my_card)
  #     if my_previous_card.card == "Claim:Thief" do
  #       right_player_card_number = rem(active_player_card_number - 1, 4)
  #       right_player_previous_card = Enum.at(game.players, right_player_card_number)
  #       right_player_card = right_player_previous_card |> Map.put(:money, right_player_previous_card.money - 1)
  #       left_player_card_number = rem(active_player_card_number + 1, 4)
  #       left_player_previous_card = Enum.at(game.players, left_player_card_number)
  #       left_player_card = left_player_previous_card |> Map.put(:money, left_player_previous_card.money - 1)
  #       new_players = new_players
  #         |> List.replace_at(right_player_card_number, right_player_card)
  #         |> List.replace_at(left_player_card_number, left_player_card)
  #     end
  #     %{
  #       players: new_players,
  #       free_cards: game.free_cards,
  #       court_money: game.court_money,
  #       round: game.round + 1,
  #       active_player: new_active_player + 1,
  #     }
  #   else
  #     %{
  #       players: game.players,
  #       free_cards: game.free_cards,
  #       court_money: game.court_money,
  #       round: game.round,
  #       active_player: new_active_player,
  #     }
  #   end
  # end
end
