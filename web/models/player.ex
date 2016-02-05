defmodule ElMascarar.Player do
  use ElMascarar.Web, :model

  schema "players" do
    field :money, :integer

    has_one :card, Card
    belongs_to :game, Game
    timestamps
  end

  @required_fields ~w(game_id)
  @optional_fields ~w(money card)

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
