require "test_helper"

class PlaylistTracksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @playlist_track = playlist_tracks(:one)
  end

  test "should get index" do
    get playlist_tracks_url
    assert_response :success
  end

  test "should get new" do
    get new_playlist_track_url
    assert_response :success
  end

  test "should create playlist_track" do
    assert_difference("PlaylistTrack.count") do
      post playlist_tracks_url, params: { playlist_track: { playlist_id: @playlist_track.playlist_id, track_id: @playlist_track.track_id } }
    end

    assert_redirected_to playlist_track_url(PlaylistTrack.last)
  end

  test "should show playlist_track" do
    get playlist_track_url(@playlist_track)
    assert_response :success
  end

  test "should get edit" do
    get edit_playlist_track_url(@playlist_track)
    assert_response :success
  end

  test "should update playlist_track" do
    patch playlist_track_url(@playlist_track), params: { playlist_track: { playlist_id: @playlist_track.playlist_id, track_id: @playlist_track.track_id } }
    assert_redirected_to playlist_track_url(@playlist_track)
  end

  test "should destroy playlist_track" do
    assert_difference("PlaylistTrack.count", -1) do
      delete playlist_track_url(@playlist_track)
    end

    assert_redirected_to playlist_tracks_url
  end
end
