class HomeController < ApplicationController
  def index
    skip_authorization

    @table_stats = dashboard_models
      .map { |model| build_table_stat(model) }
      .sort_by { |stat| [-stat[:count], stat[:label]] }
    @total_records = @table_stats.sum { |stat| stat[:count] }
    @largest_table = @table_stats.max_by { |stat| stat[:count] }
  end

  private

  def dashboard_models
    [
      Artist,
      Album,
      Customer,
      Employee,
      Genre,
      Invoice,
      InvoiceLine,
      MediaType,
      Playlist,
      PlaylistTrack,
      Track
    ]
  end

  def build_table_stat(model)
    count = model.respond_to?(:cached_count) ? model.cached_count : model.count

    {
      model: model,
      label: model.model_name.human(count: 2),
      table_name: model.table_name,
      count: count
    }
  end
end
