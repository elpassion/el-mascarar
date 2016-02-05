defmodule ElMascarar.Game do
  use ElMascarar.Web, :model
  alias ElMascarar.GameState

  schema "games" do
    field :game_state, :map
    has_many :players, Player
    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w(game_state)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
#
  def find_or_create() do
   case all_games = Repo.all(Game) do
     [] -> create
     _ ->
       last_game = all_games |> List.last |> Repo.preload(:players)
       players_count = last_game.players |> Enum.count
       if players_count < 4 do
         last_game
       else
         create
       end
   end
  end

  def create() do
    game_state = GameState.create_game(["Queen", "King", "Judge", "Bishop", "Thief", "Liar"])
    Repo.insert!(%Game{game_state: game_state})
  end

  def ready(game) do
    Game.changeset(game, %{game_state: (game.game_state |> GameState.ready)}) |> Repo.update!
  end

  def symbolize(object) do
    for {key, val} <- object, into: %{}, do: {String.to_atom(key), val}
  end

  def symbolized_game_state(game_state) do
    %{
      players: Enum.map(game_state["players"], fn(player) -> symbolize(player) end),
      free_cards: Enum.map(game_state["free_cards"], fn(card) -> symbolize(card) end),
      round: game_state["round"],
      court_money: game_state["court_money"],
      active_player: game_state["active_player"],
    }
  end

  def switch(game, index, switch) do
    Game.changeset(game, %{game_state: (game.game_state |> symbolized_game_state |> GameState.switch(index, switch))}) |> Repo.update!
  end

  def reveal(game) do
    player_game_state = game.game_state |> symbolized_game_state |> GameState.reveal(true)
    player_game_changeset = Game.changeset(game, %{game_state: player_game_state})
    rest_game_state = game.game_state |> symbolized_game_state |> GameState.reveal(false)
    rest_game_changeset = Game.changeset(game, %{game_state: rest_game_state})
    player_game = Repo.update!(player_game_changeset) |> Repo.preload(:players)
    rest_game = Repo.update!(rest_game_changeset) |> Repo.preload(:players)
    {player_game, rest_game}
  end
end
