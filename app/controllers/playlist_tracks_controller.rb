class PlaylistTracksController < ApplicationController
  before_action :set_playlist_track, only: %i[ show edit update destroy ]

  # GET /playlist_tracks or /playlist_tracks.json
  def index
    @pagy, @playlist_tracks = pagy(PlaylistTrack.includes(:track, :playlist).all)
  end

  # GET /playlist_tracks/1 or /playlist_tracks/1.json
  def show
  end

  # GET /playlist_tracks/new
  def new
    @playlist_track = PlaylistTrack.new
  end

  # GET /playlist_tracks/1/edit
  def edit
  end

  # POST /playlist_tracks or /playlist_tracks.json
  def create
    @playlist_track = PlaylistTrack.new(playlist_track_params)

    respond_to do |format|
      if @playlist_track.save
        format.html { redirect_to @playlist_track, notice: "Playlist track was successfully created." }
        format.json { render :show, status: :created, location: @playlist_track }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @playlist_track.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /playlist_tracks/1 or /playlist_tracks/1.json
  def update
    respond_to do |format|
      if @playlist_track.update(playlist_track_params)
        format.html { redirect_to @playlist_track, notice: "Playlist track was successfully updated." }
        format.json { render :show, status: :ok, location: @playlist_track }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @playlist_track.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /playlist_tracks/1 or /playlist_tracks/1.json
  def destroy
    @playlist_track.destroy!

    respond_to do |format|
      format.html { redirect_to playlist_tracks_path, status: :see_other, notice: "Playlist track was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_playlist_track
      @playlist_track = PlaylistTrack.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def playlist_track_params
      params.require(:playlist_track).permit(:playlist_id, :track_id)
    end
end
