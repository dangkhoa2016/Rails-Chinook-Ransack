require "test_helper"

class AlbumTest < ActiveSupport::TestCase
  # --- Validations ---
  test "valid with title and artist" do
    assert albums(:black_album).valid?
  end

  test "invalid without title" do
    album = Album.new(artist: artists(:metallica))
    assert_not album.valid?
    assert_includes album.errors[:title], "can't be blank"
  end

  test "invalid with title too long" do
    album = Album.new(title: "A" * 161, artist: artists(:metallica))
    assert_not album.valid?
  end

  test "invalid without artist" do
    album = Album.new(title: "Test Album")
    assert_not album.valid?
  end

  # --- Associations ---
  test "belongs to artist" do
    assert_equal artists(:metallica), albums(:black_album).artist
  end

  test "has many tracks" do
    assert_equal 2, albums(:black_album).tracks.count
  end

  # --- Scopes ---
  test "has_tracks scope returns albums with tracks" do
    result = Album.has_tracks(true)
    assert_includes result, albums(:black_album)
  end

  test "has_tracks false returns albums without tracks" do
    empty_album = Album.create!(title: "Empty", artist: artists(:no_albums_artist))
    result = Album.has_tracks(false)
    assert_includes result, empty_album
    assert_not_includes result, albums(:black_album)
  end

  test "with_tracks_count_in_range returns albums with correct track count" do
    # black_album has 2 tracks
    result = Album.with_tracks_count_in_range(2, 2)
    assert_includes result, albums(:black_album)

    # master_of_puppets has 1 track
    result_one = Album.with_tracks_count_in_range(1, 1)
    assert_includes result_one, albums(:master_of_puppets)
    assert_not_includes result_one, albums(:black_album)
  end

  test "with_tracks_count_in_range with only min" do
    result = Album.with_tracks_count_in_range(2)
    assert_includes result, albums(:black_album)
    assert_not_includes result, albums(:master_of_puppets)
  end

  # --- display_tracks_count ---
  test "display_tracks_count returns track count" do
    assert_equal 2, albums(:black_album).display_tracks_count
  end

  test "display_tracks_count uses attr_accessor when set" do
    album = albums(:black_album)
    album.tracks_count = 42
    assert_equal 42, album.display_tracks_count
  end

  # --- to_s ---
  test "to_s returns title" do
    assert_equal "Black Album", albums(:black_album).to_s
  end
end
