defmodule ElMascarar.Repo.Migrations.CreateCard do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :name, :string
      add :state, :string
      add :player_id, :integer
      add :game_id, :integer
      timestamps
    end

  end
end
