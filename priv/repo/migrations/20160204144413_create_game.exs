defmodule ElMascarar.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :court_money, :integer
      add :round, :integer

      timestamps
    end

  end
end
