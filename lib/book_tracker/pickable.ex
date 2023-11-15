defprotocol BookTracker.Pickable do
  def short_label(data)
  def identifier(data)
end

defimpl BookTracker.Pickable, for: BookTracker.Authors.Author do
  def short_label(author), do: "#{author.first_name} #{author.last_name}"
  def identifier(author), do: author.id
end 

defimpl BookTracker.Pickable, for: BookTracker.Books.Book do
  def short_label(book), do: "#{book.title}"
  def identifier(book), do: book.id
end
