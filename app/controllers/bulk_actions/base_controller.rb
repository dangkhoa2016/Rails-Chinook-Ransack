class BulkActions::BaseController < ApplicationController
  include Filterable
  include Sortable

  LIMIT_BULK_ACTIONS = {
    bulk_destroy: 50, # controller_name
    bulk_edit: 50, # controller_name
  }


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
    raise "You must implement this method in your controller"
  end

  def model
    raise "You must implement this method in your controller"
  end

  def model_query
    raise "You must implement this method in your controller"
  end

  private

  def check_limit
    @action = controller_name.gsub('bulk_', '')
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
    @picked_ids = params[:picked_ids].present? ? params[:picked_ids].split(',') : []
  end
end
