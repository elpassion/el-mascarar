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

  def create do
    game = Repo.insert!(%Game{round: 0, court_money: 0})
    create_cards(game)
    game
  end

  def create_cards(game) do
    Repo.insert!(%Card{name: "Queen", state: "Queen", game_id: game.id})
    Repo.insert!(%Card{name: "King", state: "King", game_id: game.id})
    Repo.insert!(%Card{name: "Thief", state: "Thief", game_id: game.id})
    Repo.insert!(%Card{name: "Bishop", state: "Bishop", game_id: game.id})
    Repo.insert!(%Card{name: "Judge", state: "Judge", game_id: game.id})
    Repo.insert!(%Card{name: "Liar", state: "Liar", game_id: game.id})
  end

  def preload(game) do
    Repo.preload game, [:players, :cards]
  end

  def serialize_to_game_state(game) do
    game = preload(game)
    %{
      players: players_cards(game),
      free_cards: game_cards(game),
      court_money: game.court_money,
      round: game.round,
      id: game.id
    }
  end

  def update_from_game_state(game_state) do
    game = Repo.get!(Game, game_state.id)
    game_changeset = Game.changeset(game, %{court_money: game_state.court_money, round: game_state.round})
    Repo.update!(game_changeset)

    players = Repo.preload(game.players, :card)
    Enum.each players |> Stream.with_index |> Stream.to_list, fn({player, index}) ->
      game_state_player = Enum.at(game_state.players, index)
      player_changeset = Player.changeset(player, %{money: game_state_player.money})
      card_changeset = Card.changeset(player.card, %{state: game_state_player.card, name: game_state_player.true_card, player_id: player.id})
      Repo.update!(player_changeset)
      Repo.update!(card_changeset)
    end

    Enum.each game_state.free_cards, fn(card) ->
      repo_card = Repo.get_by!(Card, name: card.true_card, game_id: game.id)
      card_changeset = Card.changeset(repo_card, %{state: card.card, name: card.true_card, player_id: nil})
      Repo.update!(card_changeset)
    end
  end

  defp players_cards(game) do
    players = Repo.preload(game.players, :card)
    Enum.map players, fn(player) ->
      %{card: player.card.state, true_card: player.card.name, money: player.money}
    end
  end

  defp game_cards(game) do
    query = from c in Card, where: c.game_id == ^game.id and is_nil(c.player_id)
    cards = Repo.all(query)
    Enum.map cards, fn(card) ->
      if card.player_id == nil do
        %{card: card.state, true_card: card.name}
      end
    end
  end
end
