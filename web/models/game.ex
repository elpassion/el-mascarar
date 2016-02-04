defmodule ElMascarar.Game do
  use ElMascarar.Web, :model

  schema "games" do
    field :court_money, :integer
    field :round, :integer

    has_many :players, Player
    has_many :cards, Card
    timestamps
  end

  @required_fields ~w(court_money round)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def find_or_create() do
    case all_games = Repo.all(Game) do
      [] -> Repo.insert! %Game{}
      _ ->
        last_game = all_games |> List.last |> Repo.preload(:players)
        players_count = last_game.players |> Enum.count
        if players_count < 4 do
          last_game
        else
          Repo.insert! %Game{}
        end
    end
  end
end
