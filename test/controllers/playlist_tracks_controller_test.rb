require "test_helper"

class PlaylistTracksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @playlist_track = playlist_tracks(:pt_enter_sandman)
    sign_in_admin
  end

  test "redirects to login when not signed in" do
    delete destroy_user_session_path
    get playlist_tracks_url
    assert_redirected_to new_user_session_path
  end

  test "GET index returns success" do
    get playlist_tracks_url
    assert_response :success
  end

  test "GET show returns success" do
    get playlist_track_url(@playlist_track)
    assert_response :success
  end

  test "POST create with valid params" do
    assert_difference("PlaylistTrack.count") do
      post playlist_tracks_url, params: { playlist_track: {
        playlist_id: playlists(:empty_playlist).id,
        track_id: tracks(:enter_sandman).id
      }}
    end
    assert_redirected_to playlist_track_url(PlaylistTrack.last)
  end

  test "POST create duplicate track in same playlist is rejected" do
    assert_no_difference("PlaylistTrack.count") do
      post playlist_tracks_url, params: { playlist_track: {
        playlist_id: playlists(:metal_hits).id,
        track_id: tracks(:enter_sandman).id
      }}
    end
    assert_response :unprocessable_entity
  end

  test "DELETE destroy removes playlist_track" do
    assert_difference("PlaylistTrack.count", -1) do
      delete playlist_track_url(@playlist_track)
    end
    assert_redirected_to playlist_tracks_url
  end
end
