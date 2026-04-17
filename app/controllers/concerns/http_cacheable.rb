module HttpCacheable
  extend ActiveSupport::Concern

  # Cache JSON select endpoints — rarely changes, safe to cache for 5 minutes
  def cache_json_response(model_class, keyword: nil)
    cache_key = "#{model_class.model_name.cache_key}/select/#{keyword.to_s.strip}"
    etag      = Digest::MD5.hexdigest("#{cache_key}/#{model_class.maximum(:updated_at).to_i}")

    if stale?(etag: etag, public: false)
      yield
    end
  end
end
