module Cacheable
  extend ActiveSupport::Concern

  included do
    after_commit :expire_model_cache
  end

  class_methods do
    # Cache total record count — used for pagination headers and nav badges
    def cached_count
      Rails.cache.fetch(count_cache_key, expires_in: 1.hour) { count }
    end

    # Cache list for dropdown select — called frequently from json_list_for_select_element
    def cached_for_select(keyword: nil, limit: 20)
      key = select_cache_key(keyword, limit)
      Rails.cache.fetch(key, expires_in: 30.minutes) do
        scope = keyword.present? ? ransack(name_cont: keyword).result : all
        scope.limit(limit).map { |r| { value: r.id, label: r.to_s } }
      end
    end

    def count_cache_key
      "#{model_name.cache_key}/count"
    end

    def select_cache_key(keyword, limit)
      "#{model_name.cache_key}/select/#{keyword.to_s.downcase.strip}/#{limit}"
    end

    def expire_cache!
      Rails.cache.delete_matched("#{model_name.cache_key}/*")
    end
  end

  private

  def expire_model_cache
    self.class.expire_cache!
  end
end
