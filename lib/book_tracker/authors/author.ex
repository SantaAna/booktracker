defmodule BookTracker.Authors.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :first_name, :string
    field :last_name, :string
    field :bio_notes, :string
    field :md_bio_notes, :string
    many_to_many :books, BookTracker.Books.Book, join_through: "authors_books"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:first_name, :last_name, :bio_notes, :md_bio_notes])
    |> validate_required([:first_name, :last_name])
  end
end
