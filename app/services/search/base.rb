module Search
  class Base
    class << self
      include ActionView::Helpers::TextHelper
      include Search::FieldDefinitions
      include Search::FilterParser
      include Search::CollectionHelper

      CSV_FIELDS = %w[country state city address postal_code first_name last_name composer].freeze

      # --- Must be implemented by subclasses ---

      def model
        raise NotImplementedError, 'You must implement the model method'
      end

      def search_fields
        []
      end

      def filter_templates
        []
      end

      # --- Helpers ---

      def is_csv_field?(field)
        CSV_FIELDS.include?(field)
      end

      def get_search_field(key)
        search_fields.each do |group|
          group[1].each do |field|
            return field if field[:name] == key.to_s
          end
        end
        nil
      end

      def get_translate_key(key, common = false)
        if common
          "filters.common.#{key}"
        elsif respond_to?(:model)
          "filters.#{model.to_s.underscore.singularize}.#{key}"
        else
          raise NotImplementedError, 'You must implement the model method in your subclass'
        end
      end
    end
  end
end
