class PlaylistTrack < ApplicationRecord
  include Countable

  belongs_to :playlist
  belongs_to :track
  has_one :genre, through: :track
  has_one :media_type, through: :track
  has_one :album, through: :track
  has_one :artist, through: :album
  has_many :invoice_lines, through: :track
  has_many :invoices, through: :invoice_lines
  has_many :customers, through: :invoices
  has_many :support_reps, through: :customers

  validates :playlist_id, presence: true
  validates :track_id, presence: true
  validates :track_id, uniqueness: { scope: :playlist_id, message: "already exists in this playlist" }

  # Keep legacy alias for backward compatibility with existing callers
  scope :with_record_count_by_model_in_range_for_use_as_sub_query, ->(model, min_value, max_value = nil) {
    count_in_range(model, min_value, max_value)
  }


  class << self
    def ransackable_attributes(auth_object = nil)
      ['id', 'playlist_id', 'track_id', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['playlist', 'track', 'genre', 'media_type', 'album', 'artist', 'invoice_lines', 'invoices', 'customers', 'support_reps']
    end
    
    def count_by_model_ids(model, ids)
      column_name = "#{model.to_s.singularize}_id"
      if column_names.include?(column_name)
        PlaylistTrack.where(column_name => ids).group(column_name).count('id')
      else
        {}
      end
    end
  end
end
