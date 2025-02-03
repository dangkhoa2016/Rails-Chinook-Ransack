module Tools
	class BulkEditController < ApplicationController
    def index
      fields = params[:fields].to_s.split(',')
      return render json: { error: "Fields are required" }, status: :bad_request if fields.blank?

      model = params[:model]
      return render json: { error: "Model is required" }, status: :bad_request if model.blank?

      render partial: 'tools/bulk_actions/bulk_edit_form', locals: { record: model.classify.constantize.new, fields: fields }
    end
  end
end
