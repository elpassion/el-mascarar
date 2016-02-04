defmodule ElMascarar.GameState do
  use ElMascarar.ConnCase

  test "starting state" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"]) == %{
      players: [
        %{ card: "Queen", money: 6 },
        %{ card: "King", money: 6 },
        %{ card: "Thief", money: 6 },
        %{ card: "Judge", money: 6 },
      ],
      free_cards: [
        %{ card: "Bishop" },
        %{ card: "Liar" }
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

  defp create_players_list(card_names) do
    Enum.map(card_names, fn(card_name) -> %{ card: card_name, money: 6 } end)
  end

  defp create_free_cards_list(card_names) do
    Enum.map(card_names, fn(card_name) -> %{ card: card_name } end)
  end
end
