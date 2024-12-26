class GenresController < ApplicationController
  include Filterable
  before_action :set_genre, only: %i[ show edit update destroy ]

  # GET /genres or /genres.json
  def index
    begin
      @pagy, @genres = process_filters(Genre)
    rescue => e
      if e.is_a?(Pagy::OverflowError)
        @pagy = Pagy.new(count: 0)
        @genres = Genre.none
      else
        raise e
      end
    end

    if @genres.present?
      tracks_count = Track.count_by_model_ids(:genre, @genres.pluck(:id))
      @genres.each do |genre|
        genre.tracks_count = tracks_count[genre.id] || 0
      end
    end
  end

  def json_list_for_select_element
    _, genres = pagy(Genre.ransack(name_cont: params[:keyword]).result)
    genres = genres.map do |genre|
      { value: genre.id, label: genre.name }
    end
    render json: genres
  end

  # GET /genres/1 or /genres/1.json
  def show
  end

  # GET /genres/new
  def new
    @genre = Genre.new
  end

  # GET /genres/1/edit
  def edit
  end

  # POST /genres or /genres.json
  def create
    @genre = Genre.new(genre_params)

    respond_to do |format|
      if @genre.save
        format.html { redirect_to @genre, notice: "Genre was successfully created." }
        format.json { render :show, status: :created, location: @genre }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @genre.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /genres/1 or /genres/1.json
  def update
    respond_to do |format|
      if @genre.update(genre_params)
        format.html { redirect_to @genre, notice: "Genre was successfully updated." }
        format.json { render :show, status: :ok, location: @genre }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @genre.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /genres/1 or /genres/1.json
  def destroy
    @genre.destroy!

    respond_to do |format|
      format.html { redirect_to genres_path, status: :see_other, notice: "Genre was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_genre
      @genre = Genre.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def genre_params
      params.require(:genre).permit(:name)
    end

    def default_ransack_params
      :name_cont
    end
end
