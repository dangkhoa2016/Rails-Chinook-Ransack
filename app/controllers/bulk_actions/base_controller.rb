class BulkActions::BaseController < ApplicationController
  include Filterable
  include Sortable

  LIMIT_BULK_ACTIONS = {
    bulk_destroy: 50, # controller_name
    bulk_edit: 50, # controller_name
  }.freeze

  helper_method :bulk_action_create_path, :picked_ids_csv, :model

  before_action :load_records, only: [:new, :create]
  before_action :check_limit, only: [:new, :create]

  def load_records
    if picked_ids.present?
      @records = model.where(id: picked_ids)
    else
      @records = process_filters(model_query)
    end
  end

  def create
    raise NotImplementedError, 'You must implement this method in your controller'
  end

  def model
    @model ||= begin
      model_name = params[:controller].to_s.split('/').second.to_s.singularize.classify
      model_name.safe_constantize || raise(NameError, "Unable to resolve model: #{model_name}")
    end
  end

  def model_query
    model.all
  end

  private

  def picked_ids_csv
    picked_ids.join(',')
  end

  def bulk_action_create_path
    url_for(controller: params[:controller], action: :create, only_path: true)
  end

  def check_limit
    @action = controller_name.delete_prefix('bulk_')
    @limit = LIMIT_BULK_ACTIONS[controller_name.to_sym] || 50
    if @records.size > @limit
      @model_name = model.model_name.human

      return render partial: 'bulk_actions/base/limit_exceeded'
    end
  end
  
  def process_filters(query)
    new_filters = {}
    if @filters.present?
      @filters.each do |key, value|
        if key.to_s == 'scope_name'
          scope_info = value.to_a.first
          if scope_info.last.is_a?(Hash)
            query = query.send(scope_info.first, *scope_info.last.values)
          else
            query = query.send(scope_info.first, scope_info.last)
          end

          next
        end

        new_filters[key] = value
      end
    end

    query.ransack(new_filters).result
  end

  def picked_ids
    return @picked_ids if defined?(@picked_ids)

    @picked_ids = params[:picked_ids].to_s.split(',').map(&:strip).reject(&:blank?)
  end
end
