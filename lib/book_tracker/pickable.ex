defprotocol BookTracker.Pickable do
  def short_label(data)
  def identifier(data)
end

defimpl BookTracker.Pickable, for: BookTracker.Authors.Author do
  def short_label(author), do: "#{author.first_name} #{author.last_name}"
  def identifier(author), do: author.id
end

defimpl BookTracker.Pickable, for: BookTracker.Genres.Genre do
  def short_label(genre), do: "#{genre.name}"
  def identifier(genre), do: genre.id
end
