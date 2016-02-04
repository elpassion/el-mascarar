defmodule ElMascarar.GameState do
  use ElMascarar.ConnCase

  test "starting state" do
    assert create_game(["King", "Queen", "Thief", "Judge", "Bishop", "Liar"]) == %{
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
      players: [
        %{ card: card_names[0], money: 6 },
        %{ card: card_names[1], money: 6 },
        %{ card: card_names[2], money: 6 },
        %{ card: card_names[3], money: 6 },
      ],
      free_cards: [
        %{ card: card_names[4] },
        %{ card: card_names[5] }
      ],
      court_money: 0,
    }
  end
end
