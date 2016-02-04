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
    }
  end
end
