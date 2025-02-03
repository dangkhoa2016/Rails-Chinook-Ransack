class BulkActions::BulkEditController < BulkActions::BaseController
  def create
    puts "Start updating Records: #{@records} with params: #{bulk_edit_params}"
    @records.update_all(bulk_edit_params)
  end

  def new
    @fields = (editable_fields.presence || default_fields).map { |field| [field.humanize, field] }
  end

  private

  def default_fields
    model.column_names.reject { |column| column.in? ["id"] }
  end

  def editable_fields
    []
  end

  def bulk_edit_params
    raise NotImplementedError("You must implement this method in your controller")
  end
end
