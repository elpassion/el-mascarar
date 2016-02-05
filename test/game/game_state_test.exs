defmodule ElMascarar.GameStateTest do
  import ElMascarar.GameState
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
      round: 0,
      active_player: 0,
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
     round: 0,
     active_player: 0,
   }
  end

  test "switch own card" do
    assert_raise RuntimeError, fn ->
      create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
        |> ready
        |> switch(0, true)
    end
  end

  test "switch other card" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true) == %{
      players: [
        %{ card: "SwitchedOrNot", true_card: "King", money: 6 },
        %{ card: "SwitchedOrNot", true_card: "Queen", money: 6 },
        %{ card: "Unknown", true_card: "Thief", money: 6 },
        %{ card: "Unknown", true_card: "Judge", money: 6 },
      ],
      free_cards: [
        %{ card: "Unknown", true_card: "Bishop" },
        %{ card: "Unknown", true_card: "Liar" }
      ],
      court_money: 0,
      round: 1,
      active_player: 1,
    }
  end

  test "switch second player" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true)
      |> switch(2, true) == %{
      players: [
        %{ card: "Unknown", true_card: "King", money: 6 },
        %{ card: "SwitchedOrNot", true_card: "Thief", money: 6 },
        %{ card: "SwitchedOrNot", true_card: "Queen", money: 6 },
        %{ card: "Unknown", true_card: "Judge", money: 6 },
      ],
      free_cards: [
        %{ card: "Unknown", true_card: "Bishop" },
        %{ card: "Unknown", true_card: "Liar" }
      ],
      court_money: 0,
      round: 2,
      active_player: 2,
    }
  end

  test "switch own card as second player" do
    assert_raise RuntimeError, fn ->
      create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
        |> ready
        |> switch(1, true)
        |> switch(1, true)
    end
  end

  test "switch own card as first player on 5th round" do
    assert_raise RuntimeError, fn ->
      create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
        |> ready
        |> switch(1, true)
        |> switch(0, true)
        |> switch(0, true)
        |> switch(0, true)
        |> switch(0, true)
    end
  end

  test "switch 5 times" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true)
      |> switch(2, true)
      |> switch(3, true)
      |> switch(0, true)
      |> switch(1, true) == %{
        players: [
          %{ card: "SwitchedOrNot", true_card: "Thief", money: 6 },
          %{ card: "SwitchedOrNot", true_card: "Queen", money: 6 },
          %{ card: "Unknown", true_card: "Judge", money: 6 },
          %{ card: "Unknown", true_card: "King", money: 6 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 0,
        round: 5,
        active_player: 1,
   }
  end

  test "switch free card" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(5, true) == %{
      players: [
        %{ card: "SwitchedOrNot", true_card: "Liar", money: 6 },
        %{ card: "Unknown", true_card: "King", money: 6 },
        %{ card: "Unknown", true_card: "Thief", money: 6 },
        %{ card: "Unknown", true_card: "Judge", money: 6 },
      ],
      free_cards: [
        %{ card: "Unknown", true_card: "Bishop" },
        %{ card: "SwitchedOrNot", true_card: "Queen" }
      ],
      court_money: 0,
      round: 1,
      active_player: 1,
    }
  end

  test "reveal not legal before move 4" do
    assert_raise RuntimeError, fn ->
      create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
        |> ready
        |> switch(1, true)
        |> switch(0, true)
        |> switch(0, true)
        |> reveal(false)
    end
  end

  test "reveal ok on move 4" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> reveal(false) == %{
        players: [
          %{ card: "Revealed", true_card: "Judge", money: 6 },
          %{ card: "Unknown", true_card: "King", money: 6 },
          %{ card: "Unknown", true_card: "Queen", money: 6 },
          %{ card: "Unknown", true_card: "Thief", money: 6 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 0,
        round: 5,
        active_player: 1,
      }
  end

  test "reveal shows card to owner" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> reveal(true) == %{
        players: [
          %{ card: "Judge", true_card: "Judge", money: 6 },
          %{ card: "Unknown", true_card: "King", money: 6 },
          %{ card: "Unknown", true_card: "Queen", money: 6 },
          %{ card: "Unknown", true_card: "Thief", money: 6 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 0,
        round: 5,
        active_player: 1,
      }
  end

  test "fake switching" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, false) == %{
      players: [
        %{ card: "SwitchedOrNot", true_card: "Queen", money: 6 },
        %{ card: "SwitchedOrNot", true_card: "King", money: 6 },
        %{ card: "Unknown", true_card: "Thief", money: 6 },
        %{ card: "Unknown", true_card: "Judge", money: 6 },
      ],
      free_cards: [
        %{ card: "Unknown", true_card: "Bishop" },
        %{ card: "Unknown", true_card: "Liar" }
      ],
      court_money: 0,
      round: 1,
      active_player: 1,
    }
  end

  test "activation not legal before move 4" do
    assert_raise RuntimeError, fn ->
      create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
        |> ready
        |> switch(1, true)
        |> switch(0, true)
        |> switch(0, true)
        |> activate("Queen")
    end
  end

  test "activation ok on move 4" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> activate("Queen") == %{
        players: [
          %{ card: "Claim:Queen", true_card: "Judge", money: 6 },
          %{ card: "Unknown", true_card: "King", money: 6 },
          %{ card: "Unknown", true_card: "Queen", money: 6 },
          %{ card: "Unknown", true_card: "Thief", money: 6 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 0,
        round: 4,
        active_player: 1,
      }
  end

  test "activation ok on move 4 as Judge" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> activate("Judge") == %{
        players: [
          %{ card: "Claim:Judge", true_card: "Judge", money: 6 },
          %{ card: "Unknown", true_card: "King", money: 6 },
          %{ card: "Unknown", true_card: "Queen", money: 6 },
          %{ card: "Unknown", true_card: "Thief", money: 6 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 0,
        round: 4,
        active_player: 1,
      }
  end

  test "two passes do nothing" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> activate("King")
      |> pass
      |> pass == %{
        players: [
          %{ card: "Claim:King", true_card: "Judge", money: 6 },
          %{ card: "Unknown", true_card: "King", money: 6 },
          %{ card: "Unknown", true_card: "Queen", money: 6 },
          %{ card: "Unknown", true_card: "Thief", money: 6 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 0,
        round: 4,
        active_player: 3,
      }
  end

  test "third pass executes claim" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> activate("King")
      |> pass
      |> pass
      |> pass == %{
        players: [
          %{ card: "Unknown", true_card: "Judge", money: 9 },
          %{ card: "Unknown", true_card: "King", money: 6 },
          %{ card: "Unknown", true_card: "Queen", money: 6 },
          %{ card: "Unknown", true_card: "Thief", money: 6 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 0,
        round: 5,
        active_player: 1,
      }
  end

  test "third pass executes claim as Queen" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> activate("Queen")
      |> pass
      |> pass
      |> pass == %{
        players: [
          %{ card: "Unknown", true_card: "Judge", money: 8 },
          %{ card: "Unknown", true_card: "King", money: 6 },
          %{ card: "Unknown", true_card: "Queen", money: 6 },
          %{ card: "Unknown", true_card: "Thief", money: 6 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 0,
        round: 5,
        active_player: 1,
      }
  end

  test "third pass executes claim as Thief" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> activate("Thief")
      |> pass
      |> pass
      |> pass == %{
        players: [
          %{ card: "Unknown", true_card: "Judge", money: 8 },
          %{ card: "Unknown", true_card: "King", money: 5 },
          %{ card: "Unknown", true_card: "Queen", money: 6 },
          %{ card: "Unknown", true_card: "Thief", money: 5 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 0,
        round: 5,
        active_player: 1,
      }
  end

  test "can claim to be the same card as active player" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> activate("Queen")
      |> activate("Queen") == %{
        players: [
          %{ card: "Claim:Queen", true_card: "Judge", money: 6 },
          %{ card: "Claim:Queen", true_card: "King", money: 6 },
          %{ card: "Unknown", true_card: "Queen", money: 6 },
          %{ card: "Unknown", true_card: "Thief", money: 6 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 0,
        round: 4,
        active_player: 2,
      }
  end

  test "cannot claim to be different card than active player" do
    assert_raise RuntimeError, fn ->
      create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
        |> ready
        |> switch(1, true)
        |> switch(0, true)
        |> switch(0, true)
        |> switch(0, true)
        |> activate("Queen")
        |> activate("Judge")
    end
  end

  test "players lying pay to court" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> activate("Queen")
      |> activate("Queen")
      |> pass
      |> pass == %{
        players: [
          %{ card: "Judge", true_card: "Judge", money: 5 },
          %{ card: "King", true_card: "King", money: 5 },
          %{ card: "Unknown", true_card: "Queen", money: 6 },
          %{ card: "Unknown", true_card: "Thief", money: 6 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 2,
        round: 5,
        active_player: 1,
      }
  end

  test "activated card gets bonuses after revealing all" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> activate("Queen")
      |> activate("Queen")
      |> activate("Queen")
      |> pass == %{
        players: [
          %{ card: "Judge", true_card: "Judge", money: 5 },
          %{ card: "King", true_card: "King", money: 5 },
          %{ card: "Queen", true_card: "Queen", money: 8 },
          %{ card: "Unknown", true_card: "Thief", money: 6 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 2,
        round: 5,
        active_player: 1,
      }
  end

  test "last activation shows cards" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> activate("Queen")
      |> pass
      |> pass
      |> activate("Queen") == %{
        players: [
          %{ card: "Judge", true_card: "Judge", money: 5 },
          %{ card: "Unknown", true_card: "King", money: 6 },
          %{ card: "Unknown", true_card: "Queen", money: 6 },
          %{ card: "Thief", true_card: "Thief", money: 5 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 2,
        round: 5,
        active_player: 1,
      }
  end

  test "lying causes court money to accumulate" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> switch(1, true)
      |> switch(0, true)
      |> switch(0, true)
      |> switch(0, true)
      |> activate("Queen")
      |> pass
      |> pass
      |> activate("Queen")
      |> activate("King")
      |> activate("King")
      |> pass
      |> pass == %{
        players: [
          %{ card: "Unknown", true_card: "Judge", money: 5 },
          %{ card: "King", true_card: "King", money: 9 },
          %{ card: "Queen", true_card: "Queen", money: 5 },
          %{ card: "Unknown", true_card: "Thief", money: 5 },
        ],
        free_cards: [
          %{ card: "Unknown", true_card: "Bishop" },
          %{ card: "Unknown", true_card: "Liar" }
        ],
        court_money: 3,
        round: 6,
        active_player: 2,
      }
  end
end
