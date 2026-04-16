require "test_helper"

class GenresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @genre = genres(:rock)
    sign_in_admin
  end

  test "redirects to login when not signed in" do
    delete destroy_user_session_path
    get genres_url
    assert_redirected_to new_user_session_path
  end

  test "GET index returns success" do
    get genres_url
    assert_response :success
  end

  test "GET show returns success" do
    get genre_url(@genre)
    assert_response :success
  end

  test "POST create with valid params" do
    assert_difference("Genre.count") do
      post genres_url, params: { genre: { name: "Classical" } }
    end
    assert_redirected_to genre_url(Genre.last)
  end

  test "POST create with invalid params renders new" do
    assert_no_difference("Genre.count") do
      post genres_url, params: { genre: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "PATCH update with valid params" do
    patch genre_url(@genre), params: { genre: { name: "Updated Genre" } }
    assert_redirected_to genre_url(@genre)
    assert_equal "Updated Genre", @genre.reload.name
  end

  test "DELETE destroy removes genre" do
    genre = Genre.create!(name: "To Delete")
    assert_difference("Genre.count", -1) do
      delete genre_url(genre)
    end
    assert_redirected_to genres_url
  end
end
