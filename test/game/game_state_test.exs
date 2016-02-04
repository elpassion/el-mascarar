defmodule ElMascarar.GameState do
  use ElMascarar.ConnCase

  test "starting state" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"]) == %{
      players: [
        %{ card: "Queen", true_card: "Queen", money: 6 },
        %{ card: "King", true_card: "King", money: 6 },
        %{ card: "Thief", true_card: "Thief", money: 6 },
        %{ card: "Judge", true_card: "Judge", money: 6 },
      ],
      free_cards: [
        %{ card: "Bishop", true_card: "Bishop" },
        %{ card: "Liar", true_card: "Liar" }
      ],
      court_money: 0,
    }
  end

  test "ready state" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"]) |> ready == %{
     players: [
       %{ card: "Unknown", true_card: "Queen", money: 6 },
       %{ card: "Unknown", true_card: "King", money: 6 },
       %{ card: "Unknown", true_card: "Thief", money: 6 },
       %{ card: "Unknown", true_card: "Judge", money: 6 },
     ],
     free_cards: [
       %{ card: "Unknown", true_card: "Bishop" },
       %{ card: "Unknown", true_card: "Liar" }
     ],
     court_money: 0,
   }
  end

  def create_game(card_names) do
    %{
      players: Enum.take(card_names, 4) |> create_players_list,
      free_cards: Enum.slice(card_names, 4..5) |> create_free_cards_list,
      court_money: 0,
    }
  end

  def ready(game) do
    %{
      players: game.players |> hide_cards,
      free_cards: game.free_cards |> hide_cards,
      court_money: game.court_money,
    }
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
