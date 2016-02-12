defmodule ElMascarar.GameStateTest do
  import ElMascarar.GameState
  use ElMascarar.ConnCase
  setup do
    game = create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
    {:ok, game: game}
  end

  test "starting state", %{game: game} do
    assert game == %{
      players_money: [6, 6, 6, 6],
      cards: [
        %{card: "Queen", true_card: "Queen"},
        %{card: "King", true_card: "King"},
        %{card: "Thief", true_card: "Thief"},
        %{card: "Judge", true_card: "Judge"},
        %{card: "Bishop", true_card: "Bishop"},
        %{card: "Liar", true_card: "Liar"}
      ],
      court_money: 0,
      round: 0,
    }
  end

  test "ready state", %{game: game} do
    assert %{
      cards: [
        %{card: "Unknown", true_card: "Queen"},
        %{card: "Unknown", true_card: "King"},
        %{card: "Unknown", true_card: "Thief"},
        %{card: "Unknown", true_card: "Judge"},
        %{card: "Unknown", true_card: "Bishop"},
        %{card: "Unknown", true_card: "Liar"}
      ]
    } = game |> ready
  end

  test "switch own card", %{game: game} do
    assert_raise RuntimeError, fn ->
      game |> ready |> switch(0, true)
    end
  end

  test "switch other card", %{game: game} do
    assert %{
      cards: [
        %{card: "SwitchedOrNot", true_card: "King"},
        %{card: "SwitchedOrNot", true_card: "Queen"},
        %{card: "Unknown", true_card: "Thief"},
        %{card: "Unknown", true_card: "Judge"},
        %{card: "Unknown", true_card: "Bishop"},
        %{card: "Unknown", true_card: "Liar"}
      ],
      round: 1,
    } = game |> ready |> switch(1, true)
  end

  test "switch second player", %{game: game} do
    assert %{
      cards: [
        %{card: "Unknown", true_card: "King"},
        %{card: "SwitchedOrNot", true_card: "Thief"},
        %{card: "SwitchedOrNot", true_card: "Queen"},
        %{card: "Unknown", true_card: "Judge"},
        %{card: "Unknown", true_card: "Bishop"},
        %{card: "Unknown", true_card: "Liar"}
      ],
      round: 2,
    } = game |> ready |> switch(1, true) |> switch(2, true)
  end

  test "switch own card as second player", %{game: game} do
    assert_raise RuntimeError, fn ->
       game |> ready |> switch(1, true) |> switch(1, true)
    end
  end

  test "switch own card as first player on 5th round", %{game: game} do
    assert_raise RuntimeError, fn ->
      game
        |> ready
        |> switch(1, true)
        |> switch(0, true)
        |> switch(0, true)
        |> switch(0, true)
        |> switch(0, true)
    end
  end

  test "switch 5 times", %{game: game} do
    assert %{
      cards: [
        %{card: "SwitchedOrNot", true_card: "Thief"},
        %{card: "SwitchedOrNot", true_card: "Queen"},
        %{card: "Unknown", true_card: "Judge"},
        %{card: "Unknown", true_card: "King"},
        %{card: "Unknown", true_card: "Bishop"},
        %{card: "Unknown", true_card: "Liar"}
      ],
      round: 5,
    } = game
      |> ready |> switch(1, true)
      |> switch(2, true) |> switch(3, true)
      |> switch(0, true) |> switch(1, true)
  end

  test "switch free card", %{game: game} do
    assert %{
      cards: [
        %{card: "SwitchedOrNot", true_card: "Liar"},
        %{card: "Unknown", true_card: "King"},
        %{card: "Unknown", true_card: "Thief"},
        %{card: "Unknown", true_card: "Judge"},
        %{card: "Unknown", true_card: "Bishop"},
        %{card: "SwitchedOrNot", true_card: "Queen"},
      ],
      round: 1,
    } = game |> ready |> switch(5, true)
  end

  # test "reveal not legal before move 4" do
  #   assert_raise RuntimeError, fn ->
  #     create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #       |> ready
  #       |> switch(1, true)
  #       |> switch(0, true)
  #       |> switch(0, true)
  #       |> reveal(false)
  #   end
  # end

  # test "reveal ok on move 4" do
  #   assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #     |> ready
  #     |> switch(1, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> reveal(false) == %{
  #       players: [
  #         %{ card: "Revealed", true_card: "Judge", money: 6 },
  #         %{ card: "Unknown", true_card: "King", money: 6 },
  #         %{ card: "Unknown", true_card: "Queen", money: 6 },
  #         %{ card: "Unknown", true_card: "Thief", money: 6 },
  #       ],
  #       free_cards: [
  #         %{ card: "Unknown", true_card: "Bishop" },
  #         %{ card: "Unknown", true_card: "Liar" }
  #       ],
  #       court_money: 0,
  #       round: 5,
  #       active_player: 1,
  #     }
  # end

  # test "reveal shows card to owner" do
  #   assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #     |> ready
  #     |> switch(1, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> reveal(true) == %{
  #       players: [
  #         %{ card: "Judge", true_card: "Judge", money: 6 },
  #         %{ card: "Unknown", true_card: "King", money: 6 },
  #         %{ card: "Unknown", true_card: "Queen", money: 6 },
  #         %{ card: "Unknown", true_card: "Thief", money: 6 },
  #       ],
  #       free_cards: [
  #         %{ card: "Unknown", true_card: "Bishop" },
  #         %{ card: "Unknown", true_card: "Liar" }
  #       ],
  #       court_money: 0,
  #       round: 5,
  #       active_player: 1,
  #     }
  # end

  # test "fake switching" do
  #   assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #     |> ready
  #     |> switch(1, false) == %{
  #     players: [
  #       %{ card: "SwitchedOrNot", true_card: "Queen", money: 6 },
  #       %{ card: "SwitchedOrNot", true_card: "King", money: 6 },
  #       %{ card: "Unknown", true_card: "Thief", money: 6 },
  #       %{ card: "Unknown", true_card: "Judge", money: 6 },
  #     ],
  #     free_cards: [
  #       %{ card: "Unknown", true_card: "Bishop" },
  #       %{ card: "Unknown", true_card: "Liar" }
  #     ],
  #     court_money: 0,
  #     round: 1,
  #     active_player: 1,
  #   }
  # end

  # test "activation not legal before move 4" do
  #   assert_raise RuntimeError, fn ->
  #     create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #       |> ready
  #       |> switch(1, true)
  #       |> switch(0, true)
  #       |> switch(0, true)
  #       |> activate("Queen")
  #   end
  # end

  # test "activation ok on move 4" do
  #   assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #     |> ready
  #     |> switch(1, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> activate("Queen") == %{
  #       players: [
  #         %{ card: "Claim:Queen", true_card: "Judge", money: 6 },
  #         %{ card: "Unknown", true_card: "King", money: 6 },
  #         %{ card: "Unknown", true_card: "Queen", money: 6 },
  #         %{ card: "Unknown", true_card: "Thief", money: 6 },
  #       ],
  #       free_cards: [
  #         %{ card: "Unknown", true_card: "Bishop" },
  #         %{ card: "Unknown", true_card: "Liar" }
  #       ],
  #       court_money: 0,
  #       round: 4,
  #       active_player: 1,
  #     }
  # end

  # test "activation ok on move 4 as Judge" do
  #   assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #     |> ready
  #     |> switch(1, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> activate("Judge") == %{
  #       players: [
  #         %{ card: "Claim:Judge", true_card: "Judge", money: 6 },
  #         %{ card: "Unknown", true_card: "King", money: 6 },
  #         %{ card: "Unknown", true_card: "Queen", money: 6 },
  #         %{ card: "Unknown", true_card: "Thief", money: 6 },
  #       ],
  #       free_cards: [
  #         %{ card: "Unknown", true_card: "Bishop" },
  #         %{ card: "Unknown", true_card: "Liar" }
  #       ],
  #       court_money: 0,
  #       round: 4,
  #       active_player: 1,
  #     }
  # end

  # test "two passes do nothing" do
  #   assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #     |> ready
  #     |> switch(1, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> activate("King")
  #     |> pass
  #     |> pass == %{
  #       players: [
  #         %{ card: "Claim:King", true_card: "Judge", money: 6 },
  #         %{ card: "Unknown", true_card: "King", money: 6 },
  #         %{ card: "Unknown", true_card: "Queen", money: 6 },
  #         %{ card: "Unknown", true_card: "Thief", money: 6 },
  #       ],
  #       free_cards: [
  #         %{ card: "Unknown", true_card: "Bishop" },
  #         %{ card: "Unknown", true_card: "Liar" }
  #       ],
  #       court_money: 0,
  #       round: 4,
  #       active_player: 3,
  #     }
  # end

  # test "third pass executes claim" do
  #   assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #     |> ready
  #     |> switch(1, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> activate("King")
  #     |> pass
  #     |> pass
  #     |> pass == %{
  #       players: [
  #         %{ card: "Unknown", true_card: "Judge", money: 9 },
  #         %{ card: "Unknown", true_card: "King", money: 6 },
  #         %{ card: "Unknown", true_card: "Queen", money: 6 },
  #         %{ card: "Unknown", true_card: "Thief", money: 6 },
  #       ],
  #       free_cards: [
  #         %{ card: "Unknown", true_card: "Bishop" },
  #         %{ card: "Unknown", true_card: "Liar" }
  #       ],
  #       court_money: 0,
  #       round: 5,
  #       active_player: 1,
  #     }
  # end

  # test "third pass executes claim as Queen" do
  #   assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #     |> ready
  #     |> switch(1, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> activate("Queen")
  #     |> pass
  #     |> pass
  #     |> pass == %{
  #       players: [
  #         %{ card: "Unknown", true_card: "Judge", money: 8 },
  #         %{ card: "Unknown", true_card: "King", money: 6 },
  #         %{ card: "Unknown", true_card: "Queen", money: 6 },
  #         %{ card: "Unknown", true_card: "Thief", money: 6 },
  #       ],
  #       free_cards: [
  #         %{ card: "Unknown", true_card: "Bishop" },
  #         %{ card: "Unknown", true_card: "Liar" }
  #       ],
  #       court_money: 0,
  #       round: 5,
  #       active_player: 1,
  #     }
  # end

  # test "third pass executes claim as Thief" do
  #   assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #     |> ready
  #     |> switch(1, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> activate("Thief")
  #     |> pass
  #     |> pass
  #     |> pass == %{
  #       players: [
  #         %{ card: "Unknown", true_card: "Judge", money: 8 },
  #         %{ card: "Unknown", true_card: "King", money: 5 },
  #         %{ card: "Unknown", true_card: "Queen", money: 6 },
  #         %{ card: "Unknown", true_card: "Thief", money: 5 },
  #       ],
  #       free_cards: [
  #         %{ card: "Unknown", true_card: "Bishop" },
  #         %{ card: "Unknown", true_card: "Liar" }
  #       ],
  #       court_money: 0,
  #       round: 5,
  #       active_player: 1,
  #     }
  # end

  # test "can claim to be the same card as active player" do
  #   assert create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #     |> ready
  #     |> switch(1, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> switch(0, true)
  #     |> activate("Queen")
  #     |> activate("Queen") == %{
  #       players: [
  #         %{ card: "Claim:Queen", true_card: "Judge", money: 6 },
  #         %{ card: "Claim:Queen", true_card: "King", money: 6 },
  #         %{ card: "Unknown", true_card: "Queen", money: 6 },
  #         %{ card: "Unknown", true_card: "Thief", money: 6 },
  #       ],
  #       free_cards: [
  #         %{ card: "Unknown", true_card: "Bishop" },
  #         %{ card: "Unknown", true_card: "Liar" }
  #       ],
  #       court_money: 0,
  #       round: 4,
  #       active_player: 2,
  #     }
  # end

  # test "cannot claim to be different card than active player" do
  #   assert_raise RuntimeError, fn ->
  #     create_game(["Queen", "King", "Thief", "Judge", "Bishop", "Liar"])
  #       |> ready
  #       |> switch(1, true)
  #       |> switch(0, true)
  #       |> switch(0, true)
  #       |> switch(0, true)
  #       |> activate("Queen")
  #       |> activate("Judge")
  #   end
  # end
end
