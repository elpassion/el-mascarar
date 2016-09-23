defmodule ElMascarar.GameState do
  import ElMascarar.GameState.CardOperations

  def create_game(card_names) do
    %{
      cards: card_names |> create_cards_list,
      players_money: [6, 6, 6, 6],
      court_money: 0,
      round: 0,
      active_player: 0,
      claimed_card: nil,
    }
  end

  defp authorize_action!(game, action) do
    unless authorized_actions(game)[action], do: raise "Unauthorized Action"
  end

  defp authorize_action!(game, :activate, card_name) do
    authorize_action!(game, :activate)
    if game.active_player != main_player_index(game) &&
      card_name != game.claimed_card do
      raise "Unauthorized Action"
    end
  end

  defp authorized_actions(game) do
    %{
      pass: game.claimed_card,
      switch: !game.claimed_card,
      reveal: game.round >= 4 && !game.claimed_card,
      activate: game.round >= 4,
    }
  end

  defp claiming_card?(game, player_index) do
    try do
      "Claim:" <> _ = Enum.at(game.cards, player_index).card
    rescue
      MatchError -> false
    end
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

  defp next_player_index(index) do
    rem(index + 1, 4)
  end

  defp previous_player_index(index) do
    rem(index - 1, 4)
  end

  defp change_money(game, player, ammount) do
    new_player_ammount = Enum.at(game.players_money, player) + ammount
    players_money = game.players_money |>
      List.replace_at(player, new_player_ammount)

    %{game | players_money: players_money}
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
    authorize_action!(game, :activate, card_name)
    unless game.claimed_card, do: game = %{game |> ready | claimed_card: card_name}

    game = game |>
      mark_claimed(game.active_player, card_name) |>
      increase_active_player

    if game.active_player == main_player_index(game) do
      claiming_players = game.cards |>
        Stream.with_index |>
        Enum.filter(fn({_, index}) -> game |> claiming_card?(index) end)
      game = claim_prizes(game, claiming_players)
    end

    game
  end

  def pass(game) do
    authorize_action!(game, :pass)
    game = game |> increase_active_player

    if game.active_player == main_player_index(game) do
      claiming_players = game.cards |>
        Stream.with_index |>
        Enum.filter(fn({_, index}) -> claiming_card?(game, index) end)

      if Enum.count(claiming_players) > 1 do
        game = claim_prizes(game, claiming_players)
      else
        game = game |>
          claim_prize(game.active_player, game.claimed_card) |>
          claim_prizes([]) |>
          ready
      end
    end

    game
  end

  defp claim_prizes(game, []) do
    %{game |> increase_round |> increase_active_player | claimed_card: nil}
  end

  defp claim_prizes(game, claiming_players) do
    {%{true_card: player_card}, player_index} = claiming_players |> Enum.at(0)

    if player_card == game.claimed_card do
      game = game |>
        reveal_card(player_index) |>
        claim_prize(player_index, player_card)
    else
      game = game |>
        reveal_card(player_index) |>
        change_money(player_index, -2) |>
        add_to_court
    end

    claiming_players = claiming_players |> Enum.drop(1)
    claim_prizes(game, claiming_players)
  end

  defp add_to_court(game) do
    %{game | court_money: game.court_money + 2}
  end

  defp claim_prize(game, player_index, card) do
    case card do
      "Queen" ->
        game |> change_money(player_index, 2)
      "King" ->
        game |> change_money(player_index, 3)
      "Thief" ->
        game |>
          change_money(previous_player_index(player_index), -1) |>
          change_money(next_player_index(player_index), -1) |>
          change_money(player_index, 2)
      "Judge" ->
        %{game |> change_money(player_index, game.court_money) | court_money: 0}
      "Bishop" ->
        game
    end
  end

end
