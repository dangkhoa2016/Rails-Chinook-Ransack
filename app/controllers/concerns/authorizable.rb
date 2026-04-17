module Authorizable
  extend ActiveSupport::Concern

  included do
    # Tự động authorize dựa trên action và resource variable
    before_action :authorize_resource, only: %i[show edit update destroy]
    before_action :authorize_new_resource, only: %i[new create]
  end

  private

  # Override trong controller để trả về resource instance
  def current_resource
    instance_variable_get("@#{controller_name.singularize}")
  end

  # Override để trả về model class
  def resource_class
    controller_name.classify.constantize
  end

  def authorize_resource
    authorize current_resource if current_resource
  end

  def authorize_new_resource
    authorize resource_class.new
  end
end
