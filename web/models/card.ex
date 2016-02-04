defmodule ElMascarar.Card do
  use ElMascarar.Web, :model

  schema "cards" do
    field :name, :string
    field :state, :string

    belongs_to :player, Player
    belongs_to :game, Game
    timestamps
  end

  @required_fields ~w(name state player_id game_id)
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
end
