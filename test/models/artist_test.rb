require "test_helper"

class ArtistTest < ActiveSupport::TestCase
  # --- Validations ---
  test "valid with name" do
    assert artists(:metallica).valid?
  end

  test "invalid without name" do
    artist = Artist.new
    assert_not artist.valid?
    assert_includes artist.errors[:name], "can't be blank"
  end

  # --- Associations ---
  test "has many albums" do
    assert_equal 2, artists(:metallica).albums.count
  end

  test "has many tracks through albums" do
    assert_equal 3, artists(:metallica).tracks.count
  end

  test "artist with no albums" do
    assert_equal 0, artists(:no_albums_artist).albums.count
  end

  # --- Scopes ---
  test "has_albums scope returns artists with albums" do
    result = Artist.has_albums(true)
    assert_includes result, artists(:metallica)
    assert_not_includes result, artists(:no_albums_artist)
  end

  test "has_albums false returns artists without albums" do
    result = Artist.has_albums(false)
    assert_includes result, artists(:no_albums_artist)
    assert_not_includes result, artists(:metallica)
  end

  test "with_albums_count_in_range returns correct artists" do
    # metallica has 2 albums
    result = Artist.with_albums_count_in_range(2, 2)
    assert_includes result, artists(:metallica)
    assert_not_includes result, artists(:led_zeppelin)
  end

  # --- display_albums_count ---
  test "display_albums_count returns albums count" do
    artist = artists(:metallica)
    assert_equal 2, artist.display_albums_count
  end

  test "display_albums_count uses attr_accessor when set" do
    artist = artists(:metallica)
    artist.albums_count = 99
    assert_equal 99, artist.display_albums_count
  end

  # --- to_s ---
  test "to_s returns name" do
    assert_equal "Metallica", artists(:metallica).to_s
  end
end
