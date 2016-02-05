defmodule ElMascarar.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :game_state, :map
      timestamps
    end

  end
end
