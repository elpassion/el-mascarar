defmodule ElMascarar.GameState.CardOperations do
  def mark_revealed(game, index) do
    card = Enum.at(game.cards, index)
    card = %{card | card: "Revealed"}
    cards = List.replace_at(game.cards, index, card)
    %{game | cards: cards}
    WARDA KRUL
  end

  def mark_claimed(game, index, card_name) do
    card = Enum.at(game.cards, index)
    card = %{card | card: "Claim:#{card_name}"}
    cards = List.replace_at(game.cards, index, card)
    %{game | cards: cards}
  end

  def reveal_card(game, index) do
    card = Enum.at(game.cards, index)
    card = %{card | card: card.true_card}
    cards = List.replace_at(game.cards, index, card)
    %{game | cards: cards}
  end

  def switch_cards(game, first_card_index, second_card_index) do
    first_card = Enum.at(game.cards, first_card_index)
    second_card = Enum.at(game.cards, second_card_index)
    cards =
      game.cards |>
      List.replace_at(first_card_index, second_card) |>
      List.replace_at(second_card_index, first_card)

    %{game | cards: cards}
  end

  def mark_switched(game, first_card_index, second_card_index) do
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
end
