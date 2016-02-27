defmodule ElMascarar.GameState do
  import ElMascarar.GameState.CardOperations

  def create_game(card_names) do
    %{
      cards: card_names |> create_cards_list,
      players_money: [6, 6, 6, 6],
      court_money: 0,
      round: 0,
      active_player: 0,
    }
  end

  defp authorize_action!(game, action) do
    unless authorized_actions(game)[action], do: raise "Unauthorized Action"
  end

  defp authorized_actions(game) do
    %{
      switch: true,
      reveal: game.round >= 4,
      activate: game.round >= 4,
    }
  end

  defp create_cards_list(card_names) do
    Enum.map card_names, fn(card_name) ->
      %{card: card_name, true_card: card_name}
    end
  end

  defp hide_cards(cards) do
    Enum.map(cards, fn(card) -> %{card | card: "Unknown"} end)
  end

  def ready(game) do
    %{game | cards: game.cards |> hide_cards}
  end

  defp increase_round(game) do
    %{game | round: game.round + 1}
  end

  defp increase_active_player(game) do
    %{game | active_player: rem(game.active_player + 1, 4)}
  end

  def switch(game, switched_card_index, switch?) do
    authorize_action!(game, :switch)
    if switched_card_index == game.active_player do
      raise "Cannot switch own card"
    end

    game = game |>
      ready |>
      mark_switched(game.active_player, switched_card_index)
    if switch? do
      game = game |> switch_cards(game.active_player, switched_card_index)
    end

    game |> increase_round |> increase_active_player
  end

  def reveal(game, owner?) do
    authorize_action!(game, :reveal)
    game = game |> ready |> mark_revealed(game.active_player)
    if owner? do game = game |> reveal_card(game.active_player) end

    game |> increase_round |> increase_active_player
  end

  def activate(game, card_name) do
    authorize_action!(game, :activate)
    game = game |> ready |> mark_claimed(game.active_player, card_name)

    game |> increase_active_player
  end

  def pass(game) do
    game |> increase_active_player
    # new_active_player = rem(game.active_player + 1, 4)
    # active_player_card_number = rem(game.round, 4)
    # if new_active_player == active_player_card_number do
    #   my_previous_card = Enum.at(game.players, active_player_card_number)
    #   my_card = %{
    #     card: "Unknown",
    #     true_card: my_previous_card.true_card,
    #     money: my_previous_card.money + if my_previous_card.card == "Claim:King" do 3 else 2 end,
    #   }
    #   new_players = game.players |> List.replace_at(active_player_card_number, my_card)
    #   if my_previous_card.card == "Claim:Thief" do
    #     right_player_card_number = rem(active_player_card_number - 1, 4)
    #     right_player_previous_card = Enum.at(game.players, right_player_card_number)
    #     right_player_card = right_player_previous_card |> Map.put(:money, right_player_previous_card.money - 1)
    #     left_player_card_number = rem(active_player_card_number + 1, 4)
    #     left_player_previous_card = Enum.at(game.players, left_player_card_number)
    #     left_player_card = left_player_previous_card |> Map.put(:money, left_player_previous_card.money - 1)
    #     new_players = new_players
    #     |> List.replace_at(right_player_card_number, right_player_card)
    #     |> List.replace_at(left_player_card_number, left_player_card)
    #   end
    #   %{
    #     players: new_players,
    #     free_cards: game.free_cards,
    #     court_money: game.court_money,
    #     round: game.round + 1,
    #     active_player: new_active_player + 1,
    #   }
    # else
    #   %{
    #     players: game.players,
    #     free_cards: game.free_cards,
    #     court_money: game.court_money,
    #     round: game.round,
    #     active_player: new_active_player,
    #   }
    # end
  end
end
