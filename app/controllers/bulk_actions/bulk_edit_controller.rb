class BulkActions::BulkEditController < BulkActions::BaseController
  def create
    attributes = bulk_edit_params
    if attributes.blank?
      @error_message = I18n.t('base.bulk_action_no_fields')
      return render :create, status: :unprocessable_entity
    end

    @updated_count = @records.update_all(attributes)
  rescue ActionController::ParameterMissing => e
    @error_message = e.message
    render :create, status: :unprocessable_entity
  rescue StandardError => e
    @error_message = e.message
    render :create, status: :unprocessable_entity
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

  def permitted_bulk_attributes
    association_foreign_keys = model.reflect_on_all_associations(:belongs_to).map(&:foreign_key)
    (model.column_names - ['id'] + association_foreign_keys).uniq.map(&:to_sym)
  end

  def bulk_edit_params
    param_key = model.model_name.param_key
    source_params = params[param_key]
    return {} if source_params.blank?

    source_params.permit(*permitted_bulk_attributes).to_h.reject { |_key, value| value.blank? }
  end
end
