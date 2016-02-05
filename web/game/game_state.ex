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
      allPreviousCards = game.players ++ game.free_cards
      myPreviousCard = Enum.at(game.players, active_player_card_number)
      theirPreviousCard = Enum.at(allPreviousCards, card_number)
      if switch do
        myCard = myPreviousCard |> Map.put(:true_card, theirPreviousCard.true_card) |> Map.put(:card, "SwitchedOrNot")
        theirCard = theirPreviousCard |> Map.put(:true_card, myPreviousCard.true_card) |> Map.put(:card, "SwitchedOrNot")
      else
        myCard = myPreviousCard |> Map.put(:card, "SwitchedOrNot")
        theirCard = theirPreviousCard |> Map.put(:card, "SwitchedOrNot")
      end
      allCards = allPreviousCards |> List.replace_at(active_player_card_number, myCard) |> List.replace_at(card_number, theirCard)
      %{
        players: Enum.take(allCards, 4),
        free_cards: Enum.drop(allCards, 4),
        court_money: game.court_money,
        round: game.round + 1,
        active_player: rem(game.active_player + 1, 4),
      }
    end
  end

  def new_reveal(game) do
    { reveal(game, true), reveal(game, false) }
  end

  def reveal(game, is_owner) do
    if game.round < 4 do
      raise "NotSupported"
    else
      game = ready(game)
      active_player_card_number = rem(game.round, 4)
      myPreviousCard = Enum.at(game.players, active_player_card_number)
      myCard = myPreviousCard |> Map.put(:card, if is_owner do myPreviousCard.true_card else "Revealed" end)
      %{
        players: game.players |> List.replace_at(active_player_card_number, myCard),
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
      new_active_player = rem(game.active_player + 1, 4)
      if game.active_player == round_player do
        game = ready(game)
      else
        if Enum.at(game.players, round_player).card != "Claim:#{card_name}" do
          raise "NotSupported"
        end
      end
      myPreviousCard = Enum.at(game.players, game.active_player)
      myCard = myPreviousCard |> Map.put(:card, "Claim:#{card_name}")
      new_game = %{
        players: game.players |> List.replace_at(game.active_player, myCard),
        free_cards: game.free_cards,
        court_money: game.court_money,
        round: game.round,
        active_player: new_active_player,
      }
      if new_active_player == round_player do
        new_game = show_claimed_cards(new_game)
      end
      new_game
    end
  end

  def pass(game) do
    new_active_player = rem(game.active_player + 1, 4)
    round_player = rem(game.round, 4)
    if new_active_player == round_player do
      myPreviousCard = Enum.at(game.players, round_player)
      if Enum.count(Enum.filter(game.players, fn(p) -> p.card == myPreviousCard.card end)) == 1 do
        myCard = %{
          card: "Unknown",
          true_card: myPreviousCard.true_card,
          money: myPreviousCard.money + money_for_correct_card(game, myPreviousCard),
        }
        new_players = game.players |> List.replace_at(round_player, myCard)
        if myPreviousCard.card == "Claim:Thief" do
          right_player_card_number = rem(round_player - 1, 4)
          right_player_previous_card = Enum.at(game.players, right_player_card_number)
          right_player_card = right_player_previous_card |> Map.put(:money, right_player_previous_card.money - 1)
          left_player_card_number = rem(round_player + 1, 4)
          left_player_previous_card = Enum.at(game.players, left_player_card_number)
          left_player_card = left_player_previous_card |> Map.put(:money, left_player_previous_card.money - 1)
          new_players = new_players
            |> List.replace_at(right_player_card_number, right_player_card)
            |> List.replace_at(left_player_card_number, left_player_card)
        end
        %{
          players: new_players,
          free_cards: game.free_cards,
          court_money: if myPreviousCard.card == "Claim:Judge" do 0 else game.court_money end,
          round: game.round + 1,
          active_player: new_active_player + 1,
        }
      else
        show_claimed_cards(game |> Map.put(:active_player, new_active_player))
      end
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

  def show_claimed_cards(game) do
    new_players = Enum.map(game.players, fn(p) ->
      activated = String.starts_with? p.card, "Claim:"
      if activated do
        if p.card == "Claim:#{p.true_card}" do
          %{
            card: p.true_card,
            true_card: p.true_card,
            money: p.money + money_for_correct_card(game, p),
          }
        else
          %{
            card: p.true_card,
            true_card: p.true_card,
            money: p.money - 1,
          }
        end
      else
        p
      end
    end)
    liars_count = Enum.count(Enum.filter(game.players, fn(p) ->
      p.card != "Unknown" && p.card != "Claim:#{p.true_card}"
    end))
    %{
      players: new_players,
      free_cards: game.free_cards,
      court_money: (if game |> judge_is_revealed do 0 else game.court_money end) + liars_count,
      round: game.round + 1,
      active_player: rem(game.active_player + 1, 4),
    }
  end

  def money_for_correct_card(game, playerCard) do
    if playerCard.card == "Claim:King" do
      3
    else
      if playerCard.card == "Claim:Judge" do
        game.court_money
      else
        2
      end
    end
  end

  def judge_is_revealed(game) do
    Enum.count(Enum.filter(game.players, fn(p) -> p.card == "Claim:Judge" && p.true_card == "Judge" end)) == 1
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
