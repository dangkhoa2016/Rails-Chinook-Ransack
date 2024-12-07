class InvoiceLine < ApplicationRecord
  belongs_to :invoice
  belongs_to :track
end
