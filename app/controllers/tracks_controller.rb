class TracksController < ApplicationController
  include Filterable
  include Sortable
  include HttpCacheable
  before_action :set_track, only: %i[ show edit update destroy ]
  before_action :authorize_track

  # GET /tracks or /tracks.json
  def index
    @pagy, @tracks = process_filters(model_query)

    if @tracks.present?
      invoice_lines_count = Track.count_invoice_lines_by_ids(@tracks.pluck(:id))
      @tracks.each do |track|
        track.invoice_lines_count = invoice_lines_count[track.id] || 0
      end
    end

    render_index
  end

  def json_list_for_select_element
    cache_json_response(Track, keyword: params[:keyword]) do
      _, tracks = pagy(Track.ransack(name_or_composer_cont: params[:keyword]).result)
      render json: tracks.map { |t| { value: t.id, label: t.name } }
    end
  end

  # GET /tracks/1 or /tracks/1.json
  def show
  end

  # GET /tracks/new
  def new
    @track = Track.new
  end

  # GET /tracks/1/edit
  def edit
  end

  # POST /tracks or /tracks.json
  def create
    @track = Track.new(track_params)

    respond_to do |format|
      if @track.save
        format.html { redirect_to @track, notice: "Track was successfully created." }
        format.json { render :show, status: :created, location: @track }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @track.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tracks/1 or /tracks/1.json
  def update
    respond_to do |format|
      if @track.update(track_params)
        format.html { redirect_to @track, notice: "Track was successfully updated." }
        format.json { render :show, status: :ok, location: @track }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @track.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tracks/1 or /tracks/1.json
  def destroy
    @track.destroy!

    respond_to do |format|
      format.html { redirect_to tracks_path, status: :see_other, notice: "Track was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_track
      @track = Track.find(params[:id])
    end

    def authorize_track
      authorize(@track || Track)
    end

    # Only allow a list of trusted parameters through.
    def track_params
      params.require(:track).permit(:name, :album_id, :media_type_id, :genre_id, :composer, :milliseconds, :bytes, :unit_price)
    end

    def sortable_columns
      %w[id name composer milliseconds bytes unit_price created_at updated_at invoice_lines_count]
    end

    def default_ransack_params
      :name_or_album_title_or_genre_name_or_media_type_name_cont
    end


    def model_query
      query = Track.includes(:album, :media_type, :genre)
      if is_sort_by_invoice_lines_count?
        query = query.left_joins(:invoice_lines).group('tracks.id')
      end

      query
    end

    def is_sort_by_invoice_lines_count?
      @is_sort_by_invoice_lines_count ||= (sort_column == 'invoice_lines_count')
    end

    def sorting_params
      if is_sort_by_invoice_lines_count?
        Arel.sql("COUNT(invoice_lines.id) #{sort_direction == 'asc' ? 'ASC' : 'DESC'}")
      else
        super
      end
    end
end
