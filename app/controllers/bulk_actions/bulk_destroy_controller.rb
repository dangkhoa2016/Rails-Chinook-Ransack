class BulkActions::BulkDestroyController < BulkActions::BaseController
  def create
    # @records.destroy_all
    puts "Start destroy Records: #{@records}"
    # redirect_to request.referer, notice: "Records deleted successfully"
  end
end
