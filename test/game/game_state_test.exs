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
      create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"]) |> ready |> switch(0)
    end
  end

  test "switch other card" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"]) |> ready |> switch(1) == %{
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
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"]) |> ready |> switch(1) |> switch(2) == %{
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
        |> switch(1)
        |> switch(1)
    end
  end

  test "switch own card as first player on 5th round" do
    assert_raise RuntimeError, fn ->
      create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
        |> ready
        |> switch(1)
        |> switch(0)
        |> switch(0)
        |> switch(0)
        |> switch(0)
    end
  end

  test "switch 5 times" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1)
      |> switch(2)
      |> switch(3)
      |> switch(0)
      |> switch(1) == %{
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
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"]) |> ready |> switch(5) == %{
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
        |> switch(1)
        |> switch(0)
        |> switch(0)
        |> reveal()
    end
  end

  test "reveal ok on move 4" do
    assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
      |> ready
      |> switch(1)
      |> switch(0)
      |> switch(0)
      |> switch(0)
      |> reveal() == %{
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
end