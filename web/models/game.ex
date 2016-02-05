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

  def switch(game, index, switch) do
    Game.changeset(game, %{game_state: (game.game_state |> GameState.switch(index, switch))}) |> Repo.update!
  end
end
