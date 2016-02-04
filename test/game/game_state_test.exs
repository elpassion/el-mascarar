defmodule ElMascarar.GameState do
  use ElMascarar.ConnCase

  test "starting state" do
    assert create_game() == %{
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

  def create_game() do
    %{
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
end
