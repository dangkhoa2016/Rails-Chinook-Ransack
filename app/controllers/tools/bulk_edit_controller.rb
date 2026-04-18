module Tools
	class BulkEditController < ApplicationController
    def index
      fields = params[:fields].to_s.split(',').map(&:strip).reject(&:blank?)
      return render json: { error: "Fields are required" }, status: :bad_request if fields.blank?

      model_name = params[:model].to_s.singularize.classify
      return render json: { error: "Model is required" }, status: :bad_request if model_name.blank?

      model_class = model_name.safe_constantize
      unless model_class && model_class < ApplicationRecord
        return render json: { error: "Invalid model" }, status: :bad_request
      end

      render partial: 'tools/bulk_actions/bulk_edit_form', locals: { record: model_class.new, fields: fields }
    end
  end
end
