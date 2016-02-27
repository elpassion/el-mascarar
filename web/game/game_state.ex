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

  defp main_player_index(game) do
    rem(game.round, 4)
  end

  defp next_player_index(game) do
    rem(game.active_player + 1, 4)
  end

  defp previous_player_index(game) do
    rem(game.active_player - 1, 4)
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

  defp change_money(game, player, ammount) do
    new_player_ammount = Enum.at(game.players_money, player) + ammount
    players_money = game.players_money |>
      List.replace_at(player, new_player_ammount)

    %{game | players_money: players_money}
  end

  def pass(game) do
    claiming_player_index = main_player_index(game)
    "Claim:" <> claimed_card = Enum.at(game.cards, claiming_player_index).card

    game = game |> increase_active_player

    if game.active_player == claiming_player_index do
      case claimed_card do
        "Queen" ->
          game = game |> change_money(claiming_player_index, 2)
        "King" ->
          game = game |> change_money(claiming_player_index, 3)
        "Thief" ->
          game = game |>
            change_money(previous_player_index(game), -1) |>
            change_money(next_player_index(game), -1) |>
            change_money(claiming_player_index, 2)
      end
      game = game |> ready |> increase_round
    end
    game
  end
end
