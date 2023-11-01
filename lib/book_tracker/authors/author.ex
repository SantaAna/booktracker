defmodule BookTracker.Authors.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :first_name, :string
    field :last_name, :string
    field :bio_notes, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:first_name, :last_name, :bio_notes])
    |> validate_required([:first_name, :last_name, :bio_notes])
  end
end
