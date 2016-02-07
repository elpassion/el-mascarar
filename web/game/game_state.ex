defmodule ElMascarar.GameState do

  def create_game(card_names) do
    %{
      players: Enum.take(card_names, 4) |> create_players_list,
      free_cards: Enum.drop(card_names, 4) |> create_free_cards_list,
      court_money: 0,
      round: 0,
      active_player: 0,
    }
  end

  def ready(game) do
    %{
      players: game.players |> hide_cards,
      free_cards: game.free_cards |> hide_cards,
      court_money: game.court_money,
      round: game.round,
      active_player: game.active_player,
    }
  end

  def switch(game, card_number, switch) do
    active_player_card_number = rem(game.round, 4)
    if card_number == active_player_card_number do
      raise "CannotSwitchOwnCard"
    else
      game = ready(game)
      all_previous_cards = game.players ++ game.free_cards
      my_previous_card = Enum.at(game.players, active_player_card_number)
      their_previous_card = Enum.at(all_previous_cards, card_number)
      if switch do
        my_card =
          my_previous_card |>
          Map.put(:true_card, their_previous_card.true_card) |>
          Map.put(:card, "SwitchedOrNot")
        their_card =
          their_previous_card |>
          Map.put(:true_card, my_previous_card.true_card) |>
          Map.put(:card, "SwitchedOrNot")
      else
        my_card = my_previous_card |>
          Map.put(:card, "SwitchedOrNot")
        their_card = their_previous_card |>
          Map.put(:card, "SwitchedOrNot")
      end
      all_cards = all_previous_cards |>
        List.replace_at(active_player_card_number, my_card) |>
        List.replace_at(card_number, their_card)
      %{
        players: Enum.take(all_cards, 4),
        free_cards: Enum.drop(all_cards, 4),
        court_money: game.court_money,
        round: game.round + 1,
        active_player: rem(game.active_player + 1, 4),
      }
    end
  end

  def reveal(game, is_owner) do
    if game.round < 4 do
      raise "NotSupported"
    else
      game = ready(game)
      active_player_card_number = rem(game.round, 4)
      my_previous_card = Enum.at(game.players, active_player_card_number)
      my_card = my_previous_card |> Map.put(:card, if is_owner do my_previous_card.true_card else "Revealed" end)
      %{
        players: game.players |> List.replace_at(active_player_card_number, my_card),
        free_cards: game.free_cards,
        court_money: game.court_money,
        round: game.round + 1,
        active_player: rem(game.active_player + 1, 4),
      }
    end
  end

  def activate(game, card_name) do
    if game.round < 4 do
      raise "NotSupported"
    else
      round_player = rem(game.round, 4)
      if game.active_player == round_player do
        game = ready(game)
      else
        if Enum.at(game.players, round_player).card != "Claim:#{card_name}" do
          raise "NotSupported"
        end
      end
      my_previous_card = Enum.at(game.players, game.active_player)
      my_card = my_previous_card |> Map.put(:card, "Claim:#{card_name}")
      %{
        players: game.players |> List.replace_at(game.active_player, my_card),
        free_cards: game.free_cards,
        court_money: game.court_money,
        round: game.round,
        active_player: rem(game.active_player + 1, 4),
      }
    end
  end

  def pass(game) do
    new_active_player = rem(game.active_player + 1, 4)
    active_player_card_number = rem(game.round, 4)
    if new_active_player == active_player_card_number do
      my_previous_card = Enum.at(game.players, active_player_card_number)
      my_card = %{
        card: "Unknown",
        true_card: my_previous_card.true_card,
        money: my_previous_card.money + if my_previous_card.card == "Claim:King" do 3 else 2 end,
      }
      new_players = game.players |> List.replace_at(active_player_card_number, my_card)
      if my_previous_card.card == "Claim:Thief" do
        right_player_card_number = rem(active_player_card_number - 1, 4)
        right_player_previous_card = Enum.at(game.players, right_player_card_number)
        right_player_card = right_player_previous_card |> Map.put(:money, right_player_previous_card.money - 1)
        left_player_card_number = rem(active_player_card_number + 1, 4)
        left_player_previous_card = Enum.at(game.players, left_player_card_number)
        left_player_card = left_player_previous_card |> Map.put(:money, left_player_previous_card.money - 1)
        new_players = new_players
          |> List.replace_at(right_player_card_number, right_player_card)
          |> List.replace_at(left_player_card_number, left_player_card)
      end
      %{
        players: new_players,
        free_cards: game.free_cards,
        court_money: game.court_money,
        round: game.round + 1,
        active_player: new_active_player + 1,
      }
    else
      %{
        players: game.players,
        free_cards: game.free_cards,
        court_money: game.court_money,
        round: game.round,
        active_player: new_active_player,
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
