class MediaTypesController < ApplicationController
  include Filterable
  include Sortable
  before_action :set_media_type, only: %i[ show edit update destroy ]

  # GET /media_types or /media_types.json
  def index
    begin
      @pagy, @media_types = process_filters(model_query)
    rescue => e
      if e.is_a?(Pagy::OverflowError)
        @pagy = Pagy.new(count: 0)
        @media_types = MediaType.none
      else
        raise e
      end
    end

    if @media_types.present?
      tracks_count = Track.count_by_model_ids(:media_type, @media_types.pluck(:id))
      @media_types.each do |media_type|
        media_type.tracks_count = tracks_count[media_type.id] || 0
      end
    end

    render_index
  end

  def json_list_for_select_element
    _, media_types = pagy(MediaType.ransack(name_cont: params[:keyword]).result)
    media_types = media_types.map do |media_type|
      { value: media_type.id, label: media_type.name }
    end
    render json: media_types
  end

  # GET /media_types/1 or /media_types/1.json
  def show
  end

  # GET /media_types/new
  def new
    @media_type = MediaType.new
  end

  # GET /media_types/1/edit
  def edit
  end

  # POST /media_types or /media_types.json
  def create
    @media_type = MediaType.new(media_type_params)

    respond_to do |format|
      if @media_type.save
        format.html { redirect_to @media_type, notice: "Media type was successfully created." }
        format.json { render :show, status: :created, location: @media_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @media_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /media_types/1 or /media_types/1.json
  def update
    respond_to do |format|
      if @media_type.update(media_type_params)
        format.html { redirect_to @media_type, notice: "Media type was successfully updated." }
        format.json { render :show, status: :ok, location: @media_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @media_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /media_types/1 or /media_types/1.json
  def destroy
    @media_type.destroy!

    respond_to do |format|
      format.html { redirect_to media_types_path, status: :see_other, notice: "Media type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_media_type
      @media_type = MediaType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def media_type_params
      params.require(:media_type).permit(:name)
    end

    def default_ransack_params
      :name_cont
    end

    def model_query
      query = MediaType
      if is_sort_by_tracks_count?
        query = query.left_joins(:tracks).group('media_types.id')
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
