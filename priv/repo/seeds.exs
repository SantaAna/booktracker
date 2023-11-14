# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BookTracker.Repo.insert!(%BookTracker.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Faker.Person.En
import Faker.Lorem
alias BookTracker.Repo
alias BookTracker.Authors

1..100
|> Enum.map(fn _ -> 
  %{
    first_name: first_name(),
    last_name: last_name(),
    bio_notes: paragraph() 
  }
end) 
|> Enum.each(&Authors.create_author/1)

