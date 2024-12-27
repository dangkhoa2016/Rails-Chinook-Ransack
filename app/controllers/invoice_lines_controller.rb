class InvoiceLinesController < ApplicationController
  include Filterable
  before_action :set_invoice_line, only: %i[ show edit update destroy ]

  # GET /invoice_lines or /invoice_lines.json
  def index
    begin
      @pagy, @invoice_lines = process_filters(model_query)
    rescue => e
      if e.is_a?(Pagy::OverflowError)
        @pagy = Pagy.new(count: 0)
        @invoice_lines = InvoiceLine.none
      else
        raise e
      end
    end
  end

  def json_list_for_select_element
    query = params[:keyword].to_s.strip
    if query.match?(/^\d+$/) # search by id
      result = InvoiceLine.includes(:customer).where('CAST(id AS TEXT) LIKE ?', "%#{query}%")
    else
      result = InvoiceLine.includes(:customer).ransack(invoice_customer_first_name_or_invoice_customer_last_name_cont: query).result
    end

    _, invoice_lines = pagy(result)
    invoice_lines = invoice_lines.map do |invoice_line|
      { value: invoice_line.id, label: "ID: #{invoice_line.id} - By: #{invoice_line.invoice&.customer&.full_name}" }
    end
    render json: invoice_lines
  end

  # GET /invoice_lines/1 or /invoice_lines/1.json
  def show
  end

  # GET /invoice_lines/new
  def new
    @invoice_line = InvoiceLine.new
  end

  # GET /invoice_lines/1/edit
  def edit
  end

  # POST /invoice_lines or /invoice_lines.json
  def create
    @invoice_line = InvoiceLine.new(invoice_line_params)

    respond_to do |format|
      if @invoice_line.save
        format.html { redirect_to @invoice_line, notice: "Invoice line was successfully created." }
        format.json { render :show, status: :created, location: @invoice_line }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invoice_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoice_lines/1 or /invoice_lines/1.json
  def update
    respond_to do |format|
      if @invoice_line.update(invoice_line_params)
        format.html { redirect_to @invoice_line, notice: "Invoice line was successfully updated." }
        format.json { render :show, status: :ok, location: @invoice_line }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoice_lines/1 or /invoice_lines/1.json
  def destroy
    @invoice_line.destroy!

    respond_to do |format|
      format.html { redirect_to invoice_lines_path, status: :see_other, notice: "Invoice line was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice_line
      @invoice_line = InvoiceLine.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def invoice_line_params
      params.require(:invoice_line).permit(:invoice_id, :track_id, :unit_price, :quantity)
    end


    def default_ransack_params
      :track_name_or_invoice_customer_first_name_or_invoice_customer_last_name_cont
    end

    def model_query
      if is_sort_by_track?
        InvoiceLine.left_joins(:track).preload(track: [{ album: :artist }, :genre, :media_type], invoice: [:customer])
      else
        InvoiceLine.includes(track: [{ album: :artist }, :genre, :media_type], invoice: [:customer])
      end
    end

    def is_sort_by_track?
      @is_sort_by_track ||= (params[:sort]&.downcase == 'track')
    end

    def is_sort_by_total_price?
      @is_sort_by_total_price ||= (params[:sort]&.downcase == 'total_price')
    end

    def sorting_params
      if is_sort_by_track?
        sort_direction = params[:direction] || 'desc'

        {
          'tracks.name' => sort_direction,
        }
      elsif is_sort_by_total_price?
        sort_direction = params[:direction] || 'desc'

        Arel.sql("unit_price * quantity #{sort_direction}")
      else
        super
      end
    end
end
