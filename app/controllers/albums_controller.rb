class AlbumsController < ApplicationController
  include Filterable
  include Sortable
  before_action :set_album, only: %i[ show edit update destroy ]

  # GET /albums or /albums.json
  def index
    begin
      @pagy, @albums = process_filters(model_query)
    rescue => e
      if e.is_a?(Pagy::OverflowError)
        @pagy = Pagy.new(count: 0)
        @albums = Album.none
      else
        raise e
      end
    end

    if @albums.present?
      tracks_count = Track.count_by_model_ids(:album, @albums.pluck(:id))
      @albums.each do |album|
        album.tracks_count = tracks_count[album.id] || 0
      end
    end

    render_index
  end

  def json_list_for_select_element
    _, albums = pagy(Album.ransack(title_cont: params[:keyword]).result)
    albums = albums.map do |album|
      { value: album.id, label: album.title }
    end
    render json: albums
  end

  # GET /albums/1 or /albums/1.json
  def show
  end

  # GET /albums/new
  def new
    @album = Album.new
  end

  # GET /albums/1/edit
  def edit
  end

  # POST /albums or /albums.json
  def create
    @album = Album.new(album_params)

    respond_to do |format|
      if @album.save
        format.html { redirect_to @album, notice: "Album was successfully created." }
        format.json { render :show, status: :created, location: @album }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /albums/1 or /albums/1.json
  def update
    respond_to do |format|
      if @album.update(album_params)
        format.html { redirect_to @album, notice: "Album was successfully updated." }
        format.json { render :show, status: :ok, location: @album }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /albums/1 or /albums/1.json
  def destroy
    @album.destroy!

    respond_to do |format|
      format.html { redirect_to albums_path, status: :see_other, notice: "Album was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_album
      @album = Album.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def album_params
      params.require(:album).permit(:title, :artist_id)
    end

    def default_ransack_params
      :title_or_artist_name_cont
    end

    def model_query
      query = Album.includes(:artist)
      if is_sort_by_tracks_count?
        query = query.left_joins(:tracks).group('albums.id')
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
