class Employee < ApplicationRecord
  has_many :customers, foreign_key: 'support_rep_id'
  belongs_to :reporting_to, class_name: 'Employee', optional: true, foreign_key: 'reports_to'
  has_many :subordinates, class_name: 'Employee', foreign_key: 'reports_to'
  has_many :invoices, through: :customers
  has_many :invoice_lines, through: :invoices
  has_many :tracks, through: :invoice_lines
  has_many :genres, through: :tracks, source: :genre
  has_many :media_types, through: :tracks, source: :media_type
  has_many :playlist_tracks, through: :tracks
  has_many :playlists, through: :playlist_tracks
  has_many :albums, through: :tracks, source: :album
  has_many :artists, through: :albums

  attr_accessor :customers_count, :subordinates_count


  scope :with_customers_count_in_range, -> (min_value, max_value = nil) {
    # use the sub query from Customer model
    query = Customer.with_record_count_by_employee_in_range_for_use_as_sub_query(min_value, max_value)
    if query.exists?
      where(id: query)
    else
      none
    end
  }

  scope :with_subordinates_count_in_range, -> (min_value, max_value = nil) {
    # use the sub query from Employee model
    with_record_count_by_manager_in_range_for_use_as_sub_query(min_value, max_value)
  }

  scope :with_record_count_by_manager_in_range_for_use_as_sub_query, ->(min_value, max_value = nil) {
    return Employee.none if min_value.nil? && max_value.nil?

    query = Employee.select(:reports_to).group(:reports_to)

    if min_value.present? && max_value.present?
      if min_value > max_value
        return Employee.none
      elsif min_value == max_value
        query = query.having('COUNT(id) = ?', min_value)
      else
        query = query.having('COUNT(id) BETWEEN ? AND ?', min_value, max_value)
      end
    elsif min_value.nil? && max_value.present?
      query = query.having('COUNT(id) <= ?', max_value)
    elsif min_value.present? && max_value.nil?
      query = query.having('COUNT(id) >= ?', min_value)
    end

    query
  }

  scope :has_customers, -> (has_customers = true) {
    sub_query = Customer.select('1').where('customers.support_rep_id = employees.id')
    if has_customers
      where('EXISTS (?)', sub_query)
    else
      where.not('EXISTS (?)', sub_query)
    end
  }

  scope :has_subordinates, -> (has_subordinates = true) {
    sub_query = Employee.select('1').where('e2.reports_to = employees.id').from(Employee.arel_table.as('e2'))
    if has_subordinates
      where('EXISTS (?)', sub_query)
    else
      where.not('EXISTS (?)', sub_query)
    end
  }


  def full_name
    [first_name, last_name].join(' ')
  end


  class << self
    def ransackable_attributes(auth_object = nil)
      ['id', 'first_name', 'last_name', 'title', 'reports_to', 'birth_date', 'hire_date', 'address', 'city', 'state', 'country', 'postal_code', 'phone', 'fax', 'email', 'created_at', 'updated_at']
    end

    def ransackable_associations(auth_object = nil)
      ['customers', 'reporting_to', 'subordinates', 'invoices', 'invoice_lines', 'tracks', 'genres', 'media_types', 'playlist_tracks', 'playlists', 'albums', 'artists']
    end
    
    def count_by_manager_ids(ids)
      column_name = 'reports_to'
      if column_names.include?(column_name)
        Employee.where(column_name => ids).group(column_name).count
      else
        {}
      end
    end

    def employees_ids_with_most_subordinates(has_more_than_subordinates = 5)
      Employee.group(:reports_to).having('count_id >= ?', has_more_than_subordinates_count).count('id')
    end

    def first_of_employees_ids_with_most_subordinates
      employees_ids_with_most_subordinates&.keys.first
    end

    def last_of_employees_ids_with_most_subordinates
      employees_ids_with_most_subordinates&.keys.last
    end


    def employees_ids_with_fewest_subordinates(has_fewer_than_subordinates = 5)
      Employee.group(:reports_to).having('count_id <= ?', has_fewer_than_subordinates).count('id')
    end

    def first_of_employees_ids_with_fewest_subordinates
      employees_ids_with_fewest_subordinates&.keys.first
    end

    def last_of_employees_ids_with_fewest_subordinates
      employees_ids_with_fewest_subordinates&.keys.last
    end


    def employees_ids_with_most_customers(has_more_than_customers = 5)
      Customer.group(:support_rep_id).having('count_id >= ?', has_more_than_customers).count('id')
    end

    def first_of_employees_ids_with_most_customers
      employees_ids_with_most_customers&.keys.first
    end

    def last_of_employees_ids_with_most_customers
      employees_ids_with_most_customers&.keys.last
    end


    def employees_ids_with_fewest_customers(has_fewer_than_customers = 5)
      Customer.group(:support_rep_id).having('count_id <= ?', has_fewer_than_customers).count('id')
    end

    def first_of_employees_ids_with_fewest_customers
      employees_ids_with_fewest_customers&.keys.first
    end

    def last_of_employees_ids_with_fewest_customers
      employees_ids_with_fewest_customers&.keys.last
    end
  end
end
