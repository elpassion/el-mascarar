defmodule ElMascarar.Repo.Migrations.CreatePlayer do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :game_id, :integer
      timestamps
    end
  end
end
