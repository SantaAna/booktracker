defmodule BookTracker.Genres.Genre do
  use Ecto.Schema
  import Ecto.Changeset

  schema "genres" do
    field :name, :string
    many_to_many :books, BookTracker.Books.Book, join_through: "books_genres"
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(genre, attrs) do
    genre
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
