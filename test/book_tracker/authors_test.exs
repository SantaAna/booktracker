defmodule BookTracker.AuthorsTest do
  use BookTracker.DataCase

  alias BookTracker.Authors

  describe "authors" do
    alias BookTracker.Authors.Author

    import BookTracker.AuthorsFixtures

    @invalid_attrs %{first_name: nil, last_name: nil, bio_notes: nil}

    test "list_authors/0 returns all authors" do
      author = author_fixture()
      assert Authors.list_authors() == [author]
    end

    test "get_author!/1 returns the author with given id" do
      author = author_fixture()
      assert Authors.get_author!(author.id) == author
    end

    test "create_author/1 with valid data creates a author" do
      valid_attrs = %{
        first_name: "some first_name",
        last_name: "some last_name",
        bio_notes: "some bio_notes"
      }

      assert {:ok, %Author{} = author} = Authors.create_author(valid_attrs)
      assert author.first_name == "some first_name"
      assert author.last_name == "some last_name"
      assert author.bio_notes == "some bio_notes"
    end

    test "create_author/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Authors.create_author(@invalid_attrs)
    end

    test "update_author/2 with valid data updates the author" do
      author = author_fixture()

      update_attrs = %{
        first_name: "some updated first_name",
        last_name: "some updated last_name",
        bio_notes: "some updated bio_notes"
      }

      assert {:ok, %Author{} = author} = Authors.update_author(author, update_attrs)
      assert author.first_name == "some updated first_name"
      assert author.last_name == "some updated last_name"
      assert author.bio_notes == "some updated bio_notes"
    end

    test "update_author/2 with invalid data returns error changeset" do
      author = author_fixture()
      assert {:error, %Ecto.Changeset{}} = Authors.update_author(author, @invalid_attrs)
      assert author == Authors.get_author!(author.id)
    end

    test "delete_author/1 deletes the author" do
      author = author_fixture()
      assert {:ok, %Author{}} = Authors.delete_author(author)
      assert_raise Ecto.NoResultsError, fn -> Authors.get_author!(author.id) end
    end

    test "change_author/1 returns a author changeset" do
      author = author_fixture()
      assert %Ecto.Changeset{} = Authors.change_author(author)
    end

    test "get_author_by_name/1 returns a single matching author" do
      [match_1, match_2] =
        [
          %{first_name: "dirk", last_name: "struthers"},
          %{first_name: "aiden", last_name: "ceralde"}
        ]
        |> Enum.map(&author_fixture/1)

      assert Authors.get_author_by_name("dir") == [match_1]
      assert Authors.get_author_by_name("dIr") == [match_1]
      assert Authors.get_author_by_name("aiden c") == [match_2]
      assert Authors.get_author_by_name("aiden C") == [match_2]
    end

    test "get_author_by_name/1 returns an empty list when given an empty string or a non-matching string" do
      [match_1, match_2] =
        [
          %{first_name: "dirk", last_name: "struthers"},
          %{first_name: "aiden", last_name: "ceralde"}
        ]
        |> Enum.map(&author_fixture/1)

      assert Authors.get_author_by_name("") == []
      assert Authors.get_author_by_name("boop") == []
    end

    test "get_author_by_name/1 returns multiple matches" do
      [match_1, match_2] =
        [
          %{first_name: "dirk", last_name: "struthers"},
          %{first_name: "dirk", last_name: "smith"}
        ]
        |> Enum.map(&author_fixture/1)

      assert Authors.get_author_by_name("d") == [match_1, match_2]
      assert Authors.get_author_by_name("dirk") == [match_1, match_2]
      assert Authors.get_author_by_name("dirk s") == [match_1, match_2]
    end
  end
end
