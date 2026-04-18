class BulkActions::BulkDestroyController < BulkActions::BaseController
  def new; end

  def create
    records = @records.to_a
    model.transaction do
      records.each(&:destroy!)
    end

    @deleted_count = records.size
  rescue StandardError => e
    @error_message = e.message
    render :create, status: :unprocessable_entity
  end
end
