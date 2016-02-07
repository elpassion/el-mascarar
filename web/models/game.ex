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

  def preload(game) do
    game |> Repo.preload(:players)
  end

  def find_or_create() do
   case all_games = Repo.all(Game) do
     [] -> create
     _ ->
       last_game = all_games |> List.last |> Game.preload
       if last_game.players |> Enum.count < 4 do
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
    game_state =
      game.game_state |>
      GameStateSerializer.to_map |>
      GameState.switch(index, switch)

    Game.changeset(game, %{game_state: game_state}) |> Repo.update!
  end

  def reveal(game) do
    player_game_state =
      game.game_state |>
      GameStateSerializer.to_map |>
      GameState.reveal(true)
    player_game_changeset = Game.changeset(game, %{game_state: player_game_state})

    rest_game_state =
      game.game_state |>
      GameStateSerializer.to_map |>
      GameState.reveal(false)
    rest_game_changeset = Game.changeset(game, %{game_state: rest_game_state})

    {Repo.update!(player_game_changeset), Repo.update!(rest_game_changeset)}
  end

  def serialize({first_game, second_game}) do
    {first_game |> serialize, second_game |> serialize}
  end

  def serialize(game) do
    game |> preload |> GameSerializer.to_map
  end

end
