require "test_helper"

class PlaylistTrackTest < ActiveSupport::TestCase
  # --- Validations ---
  test "valid with playlist and track" do
    assert playlist_tracks(:pt_enter_sandman).valid?
  end

  test "invalid without playlist_id" do
    pt = PlaylistTrack.new(track: tracks(:enter_sandman))
    assert_not pt.valid?
    assert_includes pt.errors[:playlist_id], "can't be blank"
  end

  test "invalid without track_id" do
    pt = PlaylistTrack.new(playlist: playlists(:rock_classics))
    assert_not pt.valid?
    assert_includes pt.errors[:track_id], "can't be blank"
  end

  test "invalid when same track added to same playlist twice" do
    pt = PlaylistTrack.new(
      playlist: playlists(:metal_hits),
      track: tracks(:enter_sandman)
    )
    assert_not pt.valid?
    assert_includes pt.errors[:track_id], "already exists in this playlist"
  end

  test "valid when same track added to different playlist" do
    pt = PlaylistTrack.new(
      playlist: playlists(:rock_classics),
      track: tracks(:enter_sandman)
    )
    assert pt.valid?
  end

  # --- Associations ---
  test "belongs to playlist" do
    assert_equal playlists(:metal_hits), playlist_tracks(:pt_enter_sandman).playlist
  end

  test "belongs to track" do
    assert_equal tracks(:enter_sandman), playlist_tracks(:pt_enter_sandman).track
  end

  test "has one genre through track" do
    assert_equal genres(:metal), playlist_tracks(:pt_enter_sandman).genre
  end
end
