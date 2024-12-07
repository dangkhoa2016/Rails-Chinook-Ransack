require "application_system_test_case"

class PlaylistTracksTest < ApplicationSystemTestCase
  setup do
    @playlist_track = playlist_tracks(:one)
  end

  test "visiting the index" do
    visit playlist_tracks_url
    assert_selector "h1", text: "Playlist tracks"
  end

  test "should create playlist track" do
    visit playlist_tracks_url
    click_on "New playlist track"

    fill_in "Playlist", with: @playlist_track.playlist_id
    fill_in "Track", with: @playlist_track.track_id
    click_on "Create Playlist track"

    assert_text "Playlist track was successfully created"
    click_on "Back"
  end

  test "should update Playlist track" do
    visit playlist_track_url(@playlist_track)
    click_on "Edit this playlist track", match: :first

    fill_in "Playlist", with: @playlist_track.playlist_id
    fill_in "Track", with: @playlist_track.track_id
    click_on "Update Playlist track"

    assert_text "Playlist track was successfully updated"
    click_on "Back"
  end

  test "should destroy Playlist track" do
    visit playlist_track_url(@playlist_track)
    click_on "Destroy this playlist track", match: :first

    assert_text "Playlist track was successfully destroyed"
  end
end
