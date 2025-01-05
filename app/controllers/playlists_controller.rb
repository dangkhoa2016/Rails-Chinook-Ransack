class PlaylistsController < ApplicationController
  include Filterable
  include Sortable
  before_action :set_playlist, only: %i[ show edit update destroy ]

  # GET /playlists or /playlists.json
  def index
    begin
      @pagy, @playlists = process_filters(model_query)
    rescue => e
      if e.is_a?(Pagy::OverflowError)
        @pagy = Pagy.new(count: 0)
        @playlists = Playlist.none
      else
        raise e
      end
    end

    if @playlists.present?
      tracks_count = Track.count_by_model_ids(:playlist, @playlists.pluck(:id))
      @playlists.each do |playlist|
        playlist.tracks_count = tracks_count[playlist.id] || 0
      end
    end

    render_index
  end

  # GET /playlists/1 or /playlists/1.json
  def show
  end

  # GET /playlists/new
  def new
    @playlist = Playlist.new
  end

  # GET /playlists/1/edit
  def edit
  end

  # POST /playlists or /playlists.json
  def create
    @playlist = Playlist.new(playlist_params)

    respond_to do |format|
      if @playlist.save
        format.html { redirect_to @playlist, notice: "Playlist was successfully created." }
        format.json { render :show, status: :created, location: @playlist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /playlists/1 or /playlists/1.json
  def update
    respond_to do |format|
      if @playlist.update(playlist_params)
        format.html { redirect_to @playlist, notice: "Playlist was successfully updated." }
        format.json { render :show, status: :ok, location: @playlist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /playlists/1 or /playlists/1.json
  def destroy
    @playlist.destroy!

    respond_to do |format|
      format.html { redirect_to playlists_path, status: :see_other, notice: "Playlist was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_playlist
      @playlist = Playlist.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def playlist_params
      params.require(:playlist).permit(:name)
    end

    def default_ransack_params
      :name_cont
    end

    def model_query
      query = Playlist
      if is_sort_by_tracks_count?
        query = query.left_joins(:tracks).group('playlists.id')
      end

      query
    end

    def is_sort_by_tracks_count?
      @is_sort_by_tracks_count ||= (sort_column == 'tracks_count')
    end

    def sorting_params
      if is_sort_by_tracks_count?
        "COUNT(tracks.id) #{sort_direction}"
      else
        super
      end
    end
end
