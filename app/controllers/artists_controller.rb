class ArtistsController < ApplicationController
  include Filterable
  include Sortable
  before_action :set_artist, only: %i[ show edit update destroy ]

  # GET /artists or /artists.json
  def index
    begin
      @pagy, @artists = process_filters(model_query)
    rescue => e
      if e.is_a?(Pagy::OverflowError)
        @pagy = Pagy.new(count: 0)
        @artists = Artist.none
      else
        raise e
      end
    end

    if @artists.present?
      albums_count = Album.count_by_artist_ids(@artists.pluck(:id))
      @artists.each do |artist|
        artist.albums_count = albums_count[artist.id] || 0
      end
    end

    render_index
  end

  def json_list_for_select_element
    _, artists = pagy(Artist.ransack(name_cont: params[:keyword]).result)
    artists = artists.map do |artist|
      { value: artist.id, label: artist.name }
    end
    render json: artists
  end

  # GET /artists/1 or /artists/1.json
  def show
  end

  # GET /artists/new
  def new
    @artist = Artist.new
  end

  # GET /artists/1/edit
  def edit
  end

  # POST /artists or /artists.json
  def create
    @artist = Artist.new(artist_params)

    respond_to do |format|
      if @artist.save
        format.html { redirect_to @artist, notice: "Artist was successfully created." }
        format.json { render :show, status: :created, location: @artist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /artists/1 or /artists/1.json
  def update
    respond_to do |format|
      if @artist.update(artist_params)
        format.html { redirect_to @artist, notice: "Artist was successfully updated." }
        format.json { render :show, status: :ok, location: @artist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @artist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /artists/1 or /artists/1.json
  def destroy
    @artist.destroy!

    respond_to do |format|
      format.html { redirect_to artists_path, status: :see_other, notice: "Artist was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_artist
      @artist = Artist.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def artist_params
      params.require(:artist).permit(:name)
    end
    
    def default_ransack_params
      :name_cont
    end

    def model_query
      if is_sort_by_albums_count?
        Artist.left_joins(:albums).group('artists.id')
      else
        Artist.includes(:albums)
      end
    end

    def is_sort_by_albums_count?
      @is_sort_by_albums_count ||= (sort_column == 'albums_count')
    end

    def sorting_params
      if is_sort_by_albums_count?
        "COUNT(albums.id) #{sort_direction}"
      else
        super
      end
    end
end
